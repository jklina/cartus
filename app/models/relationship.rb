# == Schema Information
#
# Table name: relationships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  related_id :bigint
#  relatee_id :bigint
#
# Indexes
#
#  index_relationships_on_related_id  (related_id)
#  index_relationships_on_relatee_id  (relatee_id)
#
# Foreign Keys
#
#  fk_rails_...  (related_id => users.id)
#  fk_rails_...  (relatee_id => users.id)
#

class Relationship < ApplicationRecord
  belongs_to :related, class_name: "User"
  belongs_to :relatee, class_name: "User"
end
