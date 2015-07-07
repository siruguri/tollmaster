class CmsConfig < ActiveRecord::Base
  validates :source_symbol, presence: true
end
