# frozen_string_literal: true

class UserUpdateRequest
  include ActiveModel::Model

  attr_accessor :email, :password, :avatar

  # Validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, allow_nil: true, format: { with: EMAIL_REGEX, message: "must be a valid email" }
  validates :password, allow_nil: true, length: { minimum: 6 }
  validates :avatar, allow_nil: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }

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
