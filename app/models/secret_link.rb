class SecretLink < ActiveRecord::Base
  # attr_reader :secret
  
  belongs_to :user

  validates :user, presence: true
  before_create :create_random_secret

  # Secret links are only created, never created.
  after_create :sms_the_link

  private
  def create_random_secret
    self.secret = SecureRandom.hex(12)
  end

  def sms_the_link
    SmsJob.perform_later self.user
  end
end
