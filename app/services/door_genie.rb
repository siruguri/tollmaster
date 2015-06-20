class DoorGenie
  def self.open_door
    a = Net::HTTP.get(URI(Rails.application.secrets.iobridge_door_open_url))

    if Rails.env.development?
      puts a[0..32]
    end
    true
  end
end
