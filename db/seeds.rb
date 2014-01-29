# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env

when 'development'

  # Creates 1,1 project/users  
  FactoryGirl.create(:valid_project)
  FactoryGirl.create(:valid_user)
  FactoryGirl.create(:valid_project_member)
  FactoryGirl.create(:iczn_subspecies)
  FactoryGirl.create(:icn_subvariety)

when 'production'
  # Never ever do anything.  Production should be seeded with a Rake task or deploy script if need be.

when 'test'

  # Never ever do anything. Test with FactoryGirl or inline..... 

end
