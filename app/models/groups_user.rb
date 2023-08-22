# == Schema Information
#
# Table name: groups_users
#
#  id           :integer          not null, primary key
#  active_from  :datetime
#  active_to    :datetime
#  is_active    :boolean          default(TRUE)
#  is_principal :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_user_group  (user_id,group_id,is_active) UNIQUE
#
class GroupsUser < ApplicationRecord

### Validations
  validates :is_principal,  uniqueness: { scope: [:group_id, :user_id] }
  validates :group_id,      uniqueness: { scope: :user_id }

  belongs_to :user
  belongs_to :group

end
