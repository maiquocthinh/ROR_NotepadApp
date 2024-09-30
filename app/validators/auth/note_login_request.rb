# frozen_string_literal: true

class AuthNoteLoginRequest
  include ActiveModel::Model

  attr_accessor :slug, :external_slug, :password

  # Validations
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

