class Element < ActiveRecord::Base
  validates :name, :presence => true
  attr_accessible :short_description, :name
end
