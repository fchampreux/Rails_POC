# == Schema Information
#
# Table name: parameters_lists
#
#  id          :integer          not null, primary key
#  code        :string(255)      not null
#  created_by  :string(255)      not null
#  description :json
#  is_active   :boolean          default(TRUE)
#  name        :json
#  sort_code   :string(255)
#  updated_by  :string(255)      not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint           not null
#  status_id   :bigint           default(0)
#
# Indexes
#
#  index_parameters_lists_on_code       (code) UNIQUE
#  index_parameters_lists_on_owner_id   (owner_id)
#  index_parameters_lists_on_sort_code  (sort_code)
#  index_parameters_lists_on_status_id  (status_id)
#  index_parameters_lists_on_uuid       (uuid)
#

class ParametersList < ApplicationRecord

### before filter
  before_save :set_sort_code

### Use global identifier to allow mixed aggregation
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### validation
  validates :code,  presence: true, 
                    uniqueness: {case_sensitive: false} , 
                    length: { minimum: 3, maximum: 30 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true

  belongs_to :owner,  class_name: "User",       foreign_key: "owner_id"		
  belongs_to :status, class_name: "Parameter",  foreign_key: "status_id", optional: true

  has_many :parameters, inverse_of: :parent, dependent: :destroy

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']

### Public functions definitions

### private functions definitions
  private

end
