# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

### Initialise application administration tables
# Application configuration: parameters_lists, parameters
# User management: users, groups, groups_users
# Authorisations: groups_roles

puts "Seeding parameters lists"
# Only parameters required for the application to start are created here after. The rest of parameters should be imported throug Excel sheets.
if ParametersList.count == 0
  puts "Initialising parameters lists"
  ParametersList.without_callback(:validation, :before, :set_code) do
    ParametersList.create(id: 0, code: 'LIST_OF_UNDEFINED', name: {"en"=>"List of Undefined"}, description: {"en"=>"This list is assigned an undefined value"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
    ParametersList.create(code: 'LIST_OF_DISPLAY_PARAMETERS', name: {"en"=>"List of display parameters"}, description: {"en"=>"This list contains display settings for users"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
    ParametersList.create(code: 'LIST_OF_LANGUAGES', name: {"en"=>"List of languages"}, description: {"en"=>"This list contains translated localizations"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
    ParametersList.create(code: 'LIST_OF_STATUSES', name: {"en"=>"List of statuses"}, description: {"en"=>"This list contains statuses allowed values"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
    ParametersList.create(code: 'LIST_OF_OBJECT_TYPES', name: {"en"=>"List of object types"}, description: {"en"=>"This list contains objects types"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
    ParametersList.create(code: 'LIST_OF_USER_ROLES', name: {"en"=>"List of user roles"}, description: {"en"=>"This list contains user roles"}, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  end

  puts ParametersList.all.map { |list| list.code }
  Rails.logger.backend.info 'Created parameters lists:'
  Rails.logger.backend.info ParametersList.all.map { |list| list.code }
  puts '---'

end

puts "Seeding parameters"
if Parameter.count == 0
  puts "Initialising parameters" 
  # List of undefined values
  Parameter.create(id: 0, name: {"en"=>"Undefined"}, code: 'UNDEFINED', property: '0', description: {"en"=>"Undefined parameter"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: 0)
  # List of statuses
  Parameter.create(name: {"en"=>"New"}, code: 'NEW', property: '0', description: {"en"=>"Status is New"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_STATUSES').id )
  # List of display parameters
  Parameter.create(name: {"en"=>"Nb of lines"}, code: 'LINES', property: '10', description: {"en"=>"Number of lines to display in lists"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_DISPLAY_PARAMETERS').id )
  # List of languages
  Parameter.create(name: {"en"=>"English"}, code: 'en', property: 'en', description: {"en"=>"Translation language"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_LANGUAGES').id )
  # List of object types - used for importation feature
  Parameter.create(name: {"en"=>"Parameters List"},    code: 'ParametersList',    property: 'PL', scope: 'import, manage', description: {"en"=>"Lists of parameters"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_OBJECT_TYPES').id )
  Parameter.create(name: {"en"=>"Parameter"},          code: 'Parameter',         property: 'PARAM', scope: '', description: {"en"=>"Parameter as an item of a parameters list"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_OBJECT_TYPES').id )
  Parameter.create(name: {"en"=>"User"},               code: 'User',              property: 'USER', scope: 'import, manage', description: {"en"=>"Users of the application"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_OBJECT_TYPES').id )
  Parameter.create(name: {"en"=>"Group"},              code: 'Group',             property: 'GROUP', scope: 'import, manage', description: {"en"=>"User groups of the application"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_OBJECT_TYPES').id )
  # List basic roles
  Parameter.create(name: {"en"=>"Administrator"},        code: 'Admin',           property: 'ADMIN', scope: 'import, manage', description: {"en"=>"Administrators of the application"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_USER_ROLES').id )
  Parameter.create(name: {"en"=>"Author"},               code: 'Author',          property: 'AUTHOR', scope: 'import, manage', description: {"en"=>"Authors of the application"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_USER_ROLES').id )
  Parameter.create(name: {"en"=>"Reader"},               code: 'Reader',          property: 'READER', scope: 'import, manage', description: {"en"=>"Readers of the application"}, active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by_code('LIST_OF_USER_ROLES').id )

  puts Parameter.all.map { |list| "#{list.parent.code}: #{list.code}" }
  Rails.logger.backend.info 'Created parameters:'
  Rails.logger.backend.info Parameter.all.map { |list| "#{list.parent.code}: #{list.code}"} 
  puts '---'
 
end

puts "Seeding users groups"
if Group.count == 0
  puts "Creating first groups"
  Group.create(id: 0, code: 'EVERYONE', name: {"en"=>"Everyone"}, description: {"en"=>"Default group for users"}, status_id: 0, owner_id: 0, created_by: 'Rake', updated_by: 'Rake')
  Group.create(code: 'ADMIN', name: {"en"=>"Administrators"}, description: {"en"=>"Software administration users"}, status_id: 0, owner_id: 0, created_by: 'Rake', updated_by: 'Rake')

  puts Group.all.map { |list| list.code }
  Rails.logger.backend.info 'Created groups:'
  Rails.logger.backend.info Group.all.map { |list| list.code }  
  puts '---'  
end

puts "Seeding groups-users" # Create links to the Everyone group as it is mandatory
if GroupsUser.count == 0
  ActiveRecord::Base.connection.execute("INSERT INTO #{ Rails.application.credentials.databases[:schemas] }.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(0, 0, true, true, current_date, current_date, current_date)")
  ActiveRecord::Base.connection.execute("INSERT INTO #{ Rails.application.credentials.databases[:schemas] }.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(1, 0, false, true, current_date, current_date, current_date)")
  ActiveRecord::Base.connection.execute("INSERT INTO #{ Rails.application.credentials.databases[:schemas] }.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(1, 1, true, true, current_date, current_date, current_date)")
end

puts "Seeding users"
if User.count == 0
  puts "Creating first users" # No translation for users
  u = User.new( id: 0, user_name: 'Unassigned', password: ENV["admin_pass"], password_confirmation: ENV["admin_pass"], organisation_id: 0, current_playground_id: 0, is_admin: 0, last_name: 'User', first_name: 'Undefined', description: {"en"=>"Undefined user"}, active_from: '2000-01-01', active_to: '2100-01-01', created_by: 'Rake', updated_by: 'Rake', owner_id: 0, email: 'support@opendataquality.com')
  u.save(validate: false)
  u = User.new( user_name: 'Admin', password: ENV["admin_pass"], password_confirmation: ENV["admin_pass"], organisation_id: 0, current_playground_id: 0, is_admin: 1, last_name: 'Administrator', first_name: 'Open Data Quality', description: {"en"=>"Admin user"}, preferred_activities: '{*}', active_from: '2000-01-01', active_to: '2100-01-01', created_by: 'Rake', updated_by: 'Rake', owner_id: 0, email: 'frederic.champreux@opendataquality.com')
  u.save(validate: false)

  puts User.all.map { |list| list.user_name }
  Rails.logger.backend.info 'Created users:'
  Rails.logger.backend.info User.all.map { |list| list.user_name }    
  puts '---'
end

puts "SQL Queries"
ActiveRecord::Base.connection.execute("update users set confirmed_at = now()")
