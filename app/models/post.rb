# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Post < ApplicationRecord
  belongs_to :user
  has_many :images, as: :imageable

  accepts_nested_attributes_for :images

  def preview_image
    images.first.variant(resize_to_fill: [1000, 220, {gravity: "Center"}])
  end
end
