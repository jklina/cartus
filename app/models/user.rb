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
#  gender             :integer
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
  has_many :reactions, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :initiated_relationships, -> { where(accepted: true) }, foreign_key: :relatee_id, dependent: :destroy, class_name: "Relationship"
  has_many :accepted_relationships, -> { where(accepted: true) }, foreign_key: :related_id, dependent: :destroy, class_name: "Relationship"
  has_many :sent_invitations, -> { where(accepted: false) }, foreign_key: :relatee_id, class_name: "Relationship"
  has_many :received_invitations, -> { where(accepted: false) }, foreign_key: :related_id, class_name: "Relationship"
  has_many :invited_friends, through: :sent_invitations, source: :related
  has_many :initiated_friends, through: :initiated_relationships, source: :related, class_name: "User"
  has_many :accepted_friends, through: :accepted_relationships, source: :relatee, class_name: "User"
  has_many :initiated_friends_posts, through: :initiated_friends, source: :posts
  has_many :accepted_friends_posts, through: :accepted_friends, source: :posts
  has_one :profile_image,
    as: :imageable,
    dependent: :destroy,
    class_name: "Image"

  enum gender: {male: 0, female: 1}

  def self.searchable_columns
    [:first_name, :last_name]
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def profile_image_url
    profile_image&.image&.variant(resize_to_fill: [385, 289, {gravity: "Center"}])
  end

  def post_thumbnail_url
    profile_image&.image&.variant(resize_to_fill: [240, 240, {gravity: "Center"}])
  end

  def friends_with?(user)
    friends_ids.include?(user.id)
  end

  def invited?(user)
    invited_friends.where(id: user.id).exists?
  end

  def friends_posts
    Post.where(user_id: friends_ids.push(id)).order(created_at: :desc)
  end

  def reaction_to(content)
    reactions.where(content: content).first
  end

  private

  def friends_ids
    relationships.pluck(:related_id, :relatee_id).flatten.uniq
  end

  def relationships
    initiated_relationships.or(accepted_relationships)
  end
end
