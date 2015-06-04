class DoorMonitorRecord < ActiveRecord::Base
  belongs_to :requestor, class_name: 'User'
end
