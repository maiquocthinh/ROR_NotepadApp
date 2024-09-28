# frozen_string_literal: true

class AuthForgotPasswordRequest
  include ActiveModel::Model

  attr_accessor :email

  # Validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "cannot be blank" },
            format: { with: EMAIL_REGEX, message: "invalid email format" }

  def errors
    super.tap do |errors|
      errors.messages.each do |attribute, messages|
        next if messages.size <= 1

        combined_message = messages.uniq.join(', ')
        errors.delete(attribute)
        errors.add(attribute, combined_message)
      end
    end
  end

end
