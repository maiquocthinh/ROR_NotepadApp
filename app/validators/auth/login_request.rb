class AuthLoginRequest
  include ActiveModel::Model

  attr_accessor :username, :password

  # Validations
  validates :username, presence: { message: "cannot be blank" }

  validates :password, presence: { message: "cannot be blank" }

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

