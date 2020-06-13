# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  birthday           :date
#  confirmation_token :string(128)
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  first_name         :string
#  last_name          :string
#  remember_token     :string(128)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email           (email)
#  index_users_on_remember_token  (remember_token)
#

class User < ApplicationRecord
  include Clearance::User

  has_many :posts, dependent: :destroy
  has_many :images, dependent: :destroy
  has_one :profile_image,
    as: :imageable,
    dependent: :destroy,
    class_name: "Image"

  def full_name
    "#{first_name} #{last_name}"
  end

  def profile_image_url
    profile_image&.image&.variant(resize_to_fill: [385, 289, {gravity: "Center"}])
  end

  def friends_with?(user)

  end
end
