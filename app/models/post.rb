# == Schema Information
#
# Table name: posts
#
#  id           :bigint           not null, primary key
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :bigint
#  user_id      :bigint           not null
#
# Indexes
#
#  index_posts_on_recipient_id  (recipient_id)
#  index_posts_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (user_id => users.id)
#

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, class_name: "User"
  has_many :images, as: :imageable, dependent: :destroy
  has_many :reactions, as: :content, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  accepts_nested_attributes_for :images

  def preview_image
    images.first.image.variant(resize_to_fill: [1000, 220, {gravity: "Center"}])
  end
end
