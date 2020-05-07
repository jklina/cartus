# == Schema Information
#
# Table name: images
#
#  id             :bigint           not null, primary key
#  description    :string
#  imageable_type :string
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  imageable_id   :bigint
#  user_id        :bigint           not null
#
# Indexes
#
#  index_images_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#  index_images_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true, optional: true
  belongs_to :user

  has_one_attached :image

  validates :image, presence: true
end
