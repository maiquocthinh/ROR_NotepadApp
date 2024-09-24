require "nanoid"

class User < ApplicationRecord
  before_create :generate_id
  before_save :downcase_email_and_username

  has_many :backup_notes, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  private

  # Generates a unique random id
  def generate_id
    self.id = IdGenerator.generate_user_id
    while User.exists?(id: self.id)
      self.id = IdGenerator.generate_user_id
    end
  end

  def downcase_email_and_username
    self.email = email.downcase
    self.username = username.downcase
  end

end
