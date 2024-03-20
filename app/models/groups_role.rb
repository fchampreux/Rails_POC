# == Schema Information
#
# Table name: groups_roles
#
#  id           :integer          not null, primary key
#  active_from  :datetime
#  active_to    :datetime
#  is_active    :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :bigint
#  parameter_id :bigint
#
# Indexes
#
#  index_groups_roles_on_group_id      (group_id)
#  index_groups_roles_on_parameter_id  (parameter_id)
#
class GroupsRole < ApplicationRecord

### Validations
  validates :group_id, uniqueness: { scope: :parameter_id }

  belongs_to :role,  class_name: "Parameter", foreign_key: "parameter_id"
  belongs_to :group

end
