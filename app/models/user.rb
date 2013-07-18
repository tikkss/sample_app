# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  
  before_save { email.downcase! }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, :email, :password, :password_confirmation, presence: true
  validates :name,  length: {maximum: 50}
  validates :email, format: {with: VALID_EMAIL_REGEX},
                      uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}
end
