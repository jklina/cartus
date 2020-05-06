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
#
# Indexes
#
#  index_images_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#

class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  has_one_attached :image

  validates :image, presence: true
end
