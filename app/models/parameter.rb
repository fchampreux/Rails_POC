# == Schema Information
#
# Table name: parameters
#
#  id                 :integer          not null, primary key
#  active_from        :datetime
#  active_to          :datetime
#  code               :string(255)      not null
#  description        :json
#  icon               :string(255)
#  name               :json
#  property           :string(255)
#  scope              :string(255)
#  sort_code          :string(255)
#  style              :string(255)
#  uuid               :uuid             not null
#  value              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parameters_list_id :bigint
#
# Indexes
#
#  index_parameters_on_code                (code,parameters_list_id) UNIQUE
#  index_parameters_on_parameters_list_id  (parameters_list_id)
#  index_parameters_on_sort_code           (sort_code)
#  index_parameters_on_uuid                (uuid)
#

class Parameter < ApplicationRecord

### validation
	validates :code,      presence: true, 
                        uniqueness: {scope: :parameters_list_id, case_sensitive: false}, 
                        length: { maximum: 32 }
	validates :property,  length: { maximum: 32 }
	validates :active_from, presence: true

  belongs_to :parent, class_name: "ParametersList", foreign_key: "parameters_list_id"

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']

### private functions definitions
  private

end
