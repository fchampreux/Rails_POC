# frozen_string_literal: true

class AdminBase < ActiveRecord::Migration[7.0]

  ############## To be executed by a superuser profile #########################
  # Run as postgres administrator role the following statements:               #
  # ## Create global sequence for application-wide identifier unicity          #
  #    CREATE SEQUENCE rails_poc_app.global_seq INCREMENT BY 1 START WITH 1;   # 
  #    GRANT SELECT, UPDATE ON SEQUENCE rails_poc_app.global_seq TO rails_user;#
  # ## Activate Crypto and UUID random functions                               #
  #    CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA rails_poc_app;         #
  #    GRANT EXECUTE ON FUNCTION dg_app.gen_random_uuid() TO rails_user;       #
  ##############################################################################

  def change

    # User management: users, groups, groups_users
    create_table "users", id: :serial do |t|
      t.uuid "uuid",                     index: true, null: false, default: -> { "gen_random_uuid()" }, comment: "UUID uniquely identifies an object"
      t.string "external_directory_uri", limit: 255
      t.string "first_name",             limit: 255
      t.string "last_name",              limit: 255
      t.string "name",                   limit: 255,               comment: "Name is provided by first-name + last-name"
      t.string "user_name",              limit: 255,  null: false, comment: "User name is used for loging in"
      t.string "language" ,              limit: 255,  default: "en", comment: "User language used to diaply translated content"
      t.json "description",                                        comment: "Description is translated."
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.boolean "is_admin",                        default: false
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.string "email",                  limit: 255, default: "",  null: false
      t.string "encrypted_password",     limit: 255, default: "",  null: false
      t.string "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count",                     default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.string "confirmation_token",     limit: 255
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "unconfirmed_email"
      t.integer "failed_attempts",                   default: 0,  null: false
      t.string "unlock_token",           limit: 255
      t.datetime "locked_at"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps null: false

      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["user_name"], name: "index_users_on_user_name", unique: true
    end

    create_table "groups", id: :serial do |t|
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.uuid "uuid",                     index: true, null: false, default: -> { "gen_random_uuid()" }, comment: "UUID uniquely identifies an object"
      t.json "name",                                               comment: "Name is translated."                                         
      t.json "description",                                        comment: "Description is translated."
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps null: false

      t.index ["code"], name: "index_group_on_code", unique: true
      t.index ["sort_code"], name: "index_groups_on_sort_code"
    end

    create_table "groups_users", id: :serial do |t|
      t.references :group,               index: false
      t.references :user,                index: false
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.boolean "is_principal",                    default: false, comment: "User's main group allows notificaions routing."
      t.timestamps null: false

      t.index ["user_id", "group_id", "is_active"], name: "index_user_group", unique: true
    end

    create_table "groups_roles", id: :serial do |t|
      t.references :parameter,           index: true
      t.references :group,               index: true
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.timestamps null: false
    end

    # Application configuration: parameters_lists, parameters
    create_table "parameters_lists", id: :serial do |t|
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.uuid "uuid",                     index: true, null: false, default: -> { "gen_random_uuid()" }, comment: "UUID uniquely identifies an object"
      t.json "name",                                               comment: "Name is translated."                                         
      t.json "description",                                        comment: "Description is translated."
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps null: false

      t.index ["code"], name: "index_parameters_lists_on_code", unique: true
      t.index ["sort_code"], name: "index_parameters_lists_on_sort_code"
    end

    create_table "parameters", id: :serial do |t|
      t.references :parameters_list,    index: true
      t.string "scope",                  limit: 255
      t.json "name",                                               comment: "Name is translated."                                         
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.uuid "uuid",                     index: true, null: false, default: -> { "gen_random_uuid()" }, comment: "UUID uniquely identifies an object"
      t.string "property",               limit: 255,               comment: "Provide a readable code mapping"
      t.json "description",                                        comment: "Description is translated."
      t.datetime "active_from",          default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.string "icon",                   limit: 255,               comment: "Icon representing the option associated to the parameter"
      t.string "style",                  limit: 255,               comment: "CSS style associated to the parameter"
      t.integer "value",                                           comment: "Value associated to the parameter"
      t.timestamps null: false

      t.index ["code", "parameters_list_id"], name: "index_parameters_on_code", unique: true
      t.index ["sort_code"], name: "index_parameters_on_sort_code"
    end 

  end
end
