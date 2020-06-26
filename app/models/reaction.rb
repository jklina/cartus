# == Schema Information
#
# Table name: reactions
#
#  id           :bigint           not null, primary key
#  content_type :string
#  sentiment    :integer          default("like"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_id   :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_reactions_on_content_type_and_content_id  (content_type,content_id)
#  index_reactions_on_user_id                      (user_id)
#

class Reaction < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :user

  enum sentiment: {like: 0, laugh: 1}
end
