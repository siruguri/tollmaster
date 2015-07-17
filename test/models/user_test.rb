require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include PhoneNumberManager
  
  self.use_transactional_fixtures = true
  
  def setup
    set_net_stubs
  end

  test 'creating a user sends an SMS' do
    u = User.new(email: 'valid_email@valid.com', password: 'admin123', phone_number: '8891207491')
    u.save!

    a = enqueued_jobs[0]
    assert_match Regexp.new(u.valid_secret_link.id.to_s), a[:args][0]["_aj_globalid"]
    assert_equal 2, a[:args].length
  end
  
  test 'correct secret link is generated' do
    encrypted_pwd = Digest::SHA256.hexdigest('has_secret_not_active_secret')
    assert_equal encrypted_pwd, users(:has_secret_not_active).valid_secret_link.secret
  end

  describe 'greeting helper' do
    it 'returns name if it exists' do
      assert_equal 'Bob Bobola', users(:user_with_name).displayable_greeting
    end
    
    it 'returns email if phone doesn\'t exist' do
      assert_equal 'just_a_user1@valid.com'[0..20] + '...', users(:user_1).displayable_greeting
    end

    it "doesn't add ellipse when not necessary" do
      assert_equal users(:short_email).email, users(:short_email).displayable_greeting
    end
    
    it 'returns phone if it exists' do
      u = users(:user_2)
      assert_equal u.phone_number, u.displayable_greeting
    end
  end

  test 'new user gets a secret link' do
    assert_difference('SecretLink.count', 1) do
      User.new(email: 'email@email.com', password: 'admin123', phone_number: '2125556666').save!
    end
  end

  test 'can make invoices' do
    assert_difference('Invoice.count', 1) do
      users(:user_with_completed_sessions).make_invoices
    end
  end

  test 'can use name saving function' do
    v = users(:user_2)
    clear_name v

    v.save_split_name('bob bobola')
    assert_equal 'bob', v.first_name
    assert_equal 'bobola', v.last_name

    clear_name v
    v.save_split_name('bob')

    assert_equal 'bob', v.first_name
    assert_equal '', v.last_name

    clear_name v
    v.save_split_name('bob shob shobola')
    v = users(:user_2)

    assert_equal 'bob shob', v.first_name
    assert_equal 'shobola', v.last_name
  end

  test '#stripe_customer_id' do
    assert_nil users(:user_2).stripe_customer_id
  end

  test 'phone number validation works' do
    v = User.new
    prev = User.create(phone_number: '4156664444')

    v.set_phone_number canonicalize_number('+14156664444')
    assert_not v.valid?

    v.set_phone_number canonicalize_number('415-666-4444 ')
    assert_not v.valid?

    v.set_phone_number canonicalize_number(' 4156664444')
    assert_not v.valid?
  end

  test 'phone number setting works' do
    v = User.new
    v.set_phone_number canonicalize_number('+0401234567890')
    v.save

    assert_equal '401234567890', v.phone_number, "#{v.phone_number} was not correct"
    assert v.is_international?, "#{v.is_international} is not correct"
  end

  test "getting a user's token" do
    assert users(:user_disabled).has_supplied_token?
    assert_not users(:user_disabled).has_valid_token?
  end
  
  private
  def clear_name(u)
    u.first_name = ''
    u.last_name = ''
  end    
end
