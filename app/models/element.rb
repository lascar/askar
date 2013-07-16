class Element < ActiveRecord::Base
  validates :name, :presence => true
end
