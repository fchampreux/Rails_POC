# == Schema Information
#
# Table name: groups
#
#  id              :integer          not null, primary key
#  code            :string(255)      not null
#  created_by      :string(255)      not null
#  description     :json
#  hierarchy_entry :integer          default(0)
#  is_active       :boolean          default(TRUE)
#  name            :json
#  sort_code       :string(255)
#  updated_by      :string(255)      not null
#  uuid            :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  owner_id        :bigint           not null
#  status_id       :bigint           default(0)
#  territory_id    :bigint           not null
#
# Indexes
#
#  index_group_on_code              (code) UNIQUE
#  index_groups_on_organisation_id  (organisation_id)
#  index_groups_on_owner_id         (owner_id)
#  index_groups_on_sort_code        (sort_code)
#  index_groups_on_status_id        (status_id)
#  index_groups_on_territory_id     (territory_id)
#  index_groups_on_uuid             (uuid)
#

class Group < ApplicationRecord

### Validations
  validates :code,        presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 30 }
  validates :created_by,  presence: true
  validates :updated_by,  presence: true

  belongs_to :owner,      class_name: "User",       foreign_key: "owner_id"		
  belongs_to :status,     class_name: "Parameter",  foreign_key: "status_id"

  # Relations
  has_many :groups_users
  has_many :users, through: :groups_users
  has_many :groups_roles
  has_many :roles, through: :groups_roles
  has_many :groups_connections
  has_many :connections, through: :groups_connections

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']

end
