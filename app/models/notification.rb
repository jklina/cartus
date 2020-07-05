# == Schema Information
#
# Table name: notifications
#
#  id          :bigint           not null, primary key
#  message     :text             not null
#  read        :boolean          default(FALSE), not null
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  target_id   :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_notifications_on_target_type_and_target_id  (target_type,target_id)
#  index_notifications_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :user

  def self.unread
    where(read: false)
  end
end
