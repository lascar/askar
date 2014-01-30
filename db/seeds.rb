# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[{:name => "element 1", :description => "first element"}, {:name => "element 2", :description => "second element"}, {:name => "element 3", :description => "third element"}, {:name => "element 4", :description => "fourth element"}].each do |element|
  Element.create(:name => element[:name], :description => element[:description])
end
