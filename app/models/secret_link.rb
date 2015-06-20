class SecretLink < ActiveRecord::Base
  attr_reader :temporary_secret
  
  belongs_to :user

  validates :user, presence: true
  before_create :create_random_secret

  # Secret links are only created, never created.
  after_create :sms_the_link

  def self.find_by_encrypted_secret(password)
    where(secret: Digest::SHA256.hexdigest(password)).first
  end
  
  private
  def create_random_secret
    @temporary_secret = SecureRandom.hex(12)
    self.secret = Digest::SHA256.hexdigest @temporary_secret
  end

  def sms_the_link
    SmsJob.perform_later self, @temporary_secret
  end
end
