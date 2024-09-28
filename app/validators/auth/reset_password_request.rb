class AuthResetPasswordRequest
  include ActiveModel::Model

  attr_accessor :password, :confirm_password

  # Validations
  validates :password, presence: { message: "cannot be blank" },
            length: { minimum: 6, message: "must be at least 6 characters" }

  validates :confirm_password, presence: { message: "cannot be blank" },
            length: { minimum: 6, message: "must be at least 6 characters" }

  validate :passwords_match

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

  private

  def passwords_match
    if password.present? && confirm_password.present? && password != confirm_password
      errors.add(:confirm_password, "does not match the password  ")
    end
  end

end
