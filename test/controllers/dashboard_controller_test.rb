require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  def setup
    @inactive_user = users(:has_secret_not_active)
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

  describe 'good secret link' do
    before do
      @inactive_user = users(:has_secret_not_active)
      get :dash, {link_secret: @inactive_user.secret_link.secret}
    end

    it 'finds user' do
      assert_template :dash
      assert assigns(:user)
      assert_match /check.*in/i, response.body        
    end

    it 'allows user to check in with payment record' do
      PaymentTokenRecord.create(user: @inactive_user, token_processor: 'stripe', token_value: "atoken")
      assert_difference('PaidSession.count', 1) do
        post :checkin, {link_secret: @inactive_user.secret_link.secret}
      end

      assert_redirected_to '/dash/' + @inactive_user.secret_link.secret
    end

    it 'fails gracefully for checkin, without payment record' do
      assert_no_difference('PaidSession.count') do
        post :checkin, {link_secret: @inactive_user.secret_link.secret}
      end

      assert_redirected_to '/dash/' + @inactive_user.secret_link.secret
      assert_match /couldn.t find/i, flash[:alert]
    end

    it 'fails gracefully for checkout, without payment record' do
        post :checkout, {link_secret: @inactive_user.secret_link.secret}
        assert_redirected_to '/dash/' + @inactive_user.secret_link.secret
    end
    
    it 'does not allow opening the door' do
      assert_no_difference('DoorMonitorRecord.count', 1) do
        post :open_sesame, {link_secret: @inactive_user.secret_link.secret}
      end

      assert_redirected_to '/dash/' + @inactive_user.secret_link.secret
      assert_match /error/, flash[:alert]
    end      
  end

  test 'good link with active session that started earlier today' do
    a=Date.today
    t=Time.new(a.year, a.month, a.day) + 2.hours
    t_later = Time.new(a.year, a.month, a.day) + 3.hours
    
    PaidSession.create(user: @inactive_user, started_at: t, active: true)
    Time.stubs(:now).returns(t_later)
    get :dash, {link_secret: @inactive_user.secret_link.secret}

    assert_match /check.*out/i, response.body
    Time.unstub(:now)
  end

  describe 'user with valid link and paid session' do
    before do
      @paid_user = users(:user_with_paid_session)

      ActionMailer::Base.deliveries.clear
    end

    it 'can open door' do
      initial_count = DoorMonitorRecord.count

      post :open_sesame, {link_secret: @paid_user.secret_link.secret}
      assert_not ActionMailer::Base.deliveries.empty?
      assert_redirected_to '/dash/' + @paid_user.secret_link.secret
     
      assert_equal initial_count + 1, DoorMonitorRecord.count
     
      rec = DoorMonitorRecord.last

      assert_equal @paid_user, rec.requestor
      assert_equal true, rec.door_response
    end

    it 'sees error when door genie fails' do
      DoorGenie.stubs(:open_door).returns false
      assert_difference('DoorMonitorRecord.count', 1) do
        post :open_sesame, {link_secret: @paid_user.secret_link.secret}
      end

      assert_redirected_to '/dash/' + @paid_user.secret_link.secret      
      assert_match /error/, flash[:alert]

      DoorGenie.unstub(:open_door)
    end

    it 'can checkout' do
      # User has been set up with only one active session
      p = PaidSession.where(user: @paid_user, active: true)
      assert_equal 1, p.size

      Time.stubs(:now).returns(p.first.started_at + 42.seconds)
      post :checkout, {link_secret: @paid_user.secret_link.secret}
      Time.unstub(:now)

      assert_redirected_to '/dash/' + @paid_user.secret_link.secret
      assert_not @paid_user.has_active_session?

      p = PaidSession.where(user: @paid_user)
      assert_equal 42, p.first.duration(unit: :seconds)
    end
  end

  describe 'after checkout' do
    before do
      @checking_out_user = users(:user_with_paid_session)
      post :checkout, {link_secret: @checking_out_user.secret_link.secret}
    end

    it 'cannot open doors anymore' do
      assert_no_difference('DoorMonitorRecord.count', 1) do
        post :open_sesame, {link_secret: @checking_out_user.secret_link.secret}
      end

      assert_match /no active session/i, flash[:alert]
    end

    it 'sees checkin link on dashboard' do
      get :dash, {link_secret: @checking_out_user.secret_link.secret}
      assert_template :dash
      assert_match /check.*in/i, response.body        
    end
  end
end
