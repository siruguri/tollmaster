require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  self.use_transactional_fixtures = true
  
  def setup
    @inactive_user = users(:has_secret_not_active)

    set_net_stubs
  end
  
  test 'routing works' do
    assert_routing '/dash/atoken', {controller: 'dashboard', action: 'dash', link_secret: 'atoken'}
    assert_routing({path: '/dash/open', method: 'post'},
                   {controller: 'dashboard', action: 'open_sesame', link_secret: 'atoken'}, {}, {link_secret: 'atoken'})
    assert_routing({path: '/dash/checkout', method: 'post'},
                   {controller: 'dashboard', action: 'checkout', link_secret: 'atoken'}, {}, {link_secret: 'atoken'})
    assert_routing({path: '/dash/checkin', method: 'post'},
                   {controller: 'dashboard', action: 'checkin', link_secret: 'atoken'}, {}, {link_secret: 'atoken'})
  end
  
  test 'bad token redirects to entry page' do
    get :dash, {link_secret: 'not a link secret'}
    assert_redirected_to root_path
    assert_match /wrong.*contact/, flash[:alert]
  end

  describe 'user with email address' do
    before do
      @email_user = users :user_with_name
      get :dash, {link_secret: 'user_with_name_secret'}
    end

    it 'finds user and asks for name' do
      assert_template :dash
      assert assigns(:user)
      assert_select('input#email_address', 0)
    end
  end
  
  describe 'good secret link' do
    before do
      @inactive_user = users(:has_secret_not_active)
      get :dash, {link_secret: 'has_secret_not_active_secret'}
    end

    it 'finds user and asks for name' do
      assert_template :dash
      assert assigns(:user)

      assert_no_match /check.out/i, response.body
      assert_match /supply.*credit/i, response.body

      assert_select('input#email_address', 1)
    end

    it 'allows user to check in with payment record' do
      queue_size = enqueued_jobs.size

      PaymentTokenRecord.create(user: @inactive_user, token_processor: 'stripe', token_value: "atoken",
                                disabled: false, customer_id: 4242)
      assert_difference('PaidSession.count', 1) do
        post :checkin, {link_secret: 'has_secret_not_active_secret'}
      end

      assert_equal ActionMailer::DeliveryJob, enqueued_jobs[queue_size][:job]
      assert_redirected_to '/dash/has_secret_not_active_secret'
    end

    it 'bars user from check in with disabled payment record' do
      PaymentTokenRecord.create(user: @inactive_user, token_processor: 'stripe', token_value: "atoken",
                                disabled: true)
      refute_difference('PaidSession.count') do
        post :checkin, {link_secret: 'has_secret_not_active_secret'}
      end
    end
    
    it 'fails gracefully for checkin, without payment record' do
      assert_no_difference('PaidSession.count') do
        post :checkin, {link_secret: 'has_secret_not_active_secret'}
      end

      assert_redirected_to '/dash/has_secret_not_active_secret'
      assert_match /couldn.t find/i, flash[:alert]
    end

    it 'fails gracefully for checkout, without payment record' do
        post :checkout, {link_secret: 'has_secret_not_active_secret'}
        assert_redirected_to '/dash/has_secret_not_active_secret'
    end
    
    it 'does not allow inactive users to open the door' do
      assert_no_difference 'DoorMonitorRecord.count' do
        post :open_sesame, {link_secret: 'has_secret_not_active_secret'}
      end

      assert_redirected_to '/dash/has_secret_not_active_secret'
      assert_match /check.in.first/i, flash[:alert]
    end
  end

  test 'good link with active session that started earlier today' do
    a=Date.today
    t=Time.new(a.year, a.month, a.day) + 12.hours
    t_later = Time.new(a.year, a.month, a.day) + 13.hours

    PaymentTokenRecord.create(user: @inactive_user, token_value: 'dummy', token_processor: 'stripex')
    PaidSession.create(user: @inactive_user, started_at: t, active: true)
    Time.stubs(:now).returns(t_later)
    get :dash, {link_secret: 'has_secret_not_active_secret'}

    assert_match /open.*door/i, response.body
    assert_match /check.*out/i, response.body
    assert_no_match /check.*in.*door/i, response.body
    
    Time.unstub(:now)
  end
  
  describe 'user with valid link and paid session' do
    before do
      @paid_user = users(:user_with_paid_session)
    end

    it 'cannot open door after hours' do
      a=Date.today
      t=Time.new(a.year, a.month, a.day) + 12.hours
      t_later = Time.new(a.year, a.month, a.day) + 23.hours + 1.minutes

      Time.stubs(:now).returns(t_later)

      get :dash, {link_secret: 'user_with_paid_session_secret'}
      assert_select('input#opendoor') do |elts|
        elts.each do |elt|
          assert_equal 'disabled', elt.attr('disabled')
        end
      end

      assert_difference('DoorMonitorRecord.count', 1) do 
        post :open_sesame, {link_secret: 'user_with_paid_session_secret'}
      end

      rec = DoorMonitorRecord.last
      assert_redirected_to '/dash/user_with_paid_session_secret'
      assert_enqueued_jobs 1 # A mail is sent
      
      assert_equal DoorGenie::DoorGenieStatus::AFTER_HOURS, rec.door_response
      assert_match /opened.*between/i, flash[:notice]
      Time.unstub :now
    end
    
    it 'can open door' do
      initial_count = DoorMonitorRecord.count
      assert_enqueued_jobs 0

      a = Date.today
      t_later = Time.new(a.year, a.month, a.day) + 12.hours

      Time.stubs(:now).returns(t_later)
      post :open_sesame, {link_secret: 'user_with_paid_session_secret'}

      assert_redirected_to '/dash/user_with_paid_session_secret'
      assert_equal initial_count + 1, DoorMonitorRecord.count
      assert_match /be open/i, flash[:notice]
      
      rec = DoorMonitorRecord.last

      assert_equal @paid_user, rec.requestor
      assert_equal DoorGenie::DoorGenieStatus::OPENED, rec.door_response

      assert_enqueued_jobs 1

      Time.unstub :now
    end

    it 'sees error when door genie fails' do
      DoorGenie.stubs(:open_door).returns DoorGenie::DoorGenieStatus::FAILED
      assert_difference('DoorMonitorRecord.count', 1) do
        post :open_sesame, {link_secret: 'user_with_paid_session_secret'}
      end

      assert_redirected_to '/dash/user_with_paid_session_secret'
      assert_match /try.again/i, flash[:alert]

      DoorGenie.unstub(:open_door)
    end

    it 'can checkout' do
      # User has been set up with only one active session
      p = PaidSession.where(user: @paid_user, active: true)
      assert_equal 1, p.size
      assert_nil p.first.duration(unit: :seconds)

      Time.stubs(:now).returns(p.first.started_at + 42.seconds)
      assert_enqueued_with(job: PrepareInvoicesJob) do
        post :checkout, {link_secret: 'user_with_paid_session_secret'}
      end
      Time.unstub(:now)

      assert_redirected_to '/dash/user_with_paid_session_secret'
      assert_match(/ out/, flash[:notice])
      assert_not @paid_user.has_active_session?

      p = PaidSession.where(user: @paid_user)
      assert_equal 42, p.first.duration(unit: :seconds)
    end
  end

  describe 'after checkout' do
    it 'has no paid sessions' do
      @checking_out_user = users(:user_with_paid_session)

      assert @checking_out_user.has_active_session?
      post :checkout, {link_secret: 'user_with_paid_session_secret'}

      assert_not @checking_out_user.has_active_session?
    end
  end

  describe 'Disabled user' do
    it 'is not asked for CC info any more' do
      get :dash, {link_secret: 'user_disabled_secret'}
      assert_select('form#payments-form', 0)
    end
  end
end
