class TestResque 
  @queue = :mailers

  def self.perform(p_id)
    UserMailer.alert_developers(p_id)
  end
end
