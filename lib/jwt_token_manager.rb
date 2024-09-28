require 'jwt'

module JwtTokenManager
  JWT_SECRET = ENV['JWT_SECRET']
  RESET_PASSWORD_EXPIRATION_TIME = ENV['JWT_RESET_PASSWORD_EXPIRATION_TIME']&.to_i || 300

  private_constant :JWT_SECRET, :RESET_PASSWORD_EXPIRATION_TIME

  module Create
    def self.reset_password(payload)
      JWT.encode(payload, JWT_SECRET, 'HS256', { exp: Time.now.to_i + RESET_PASSWORD_EXPIRATION_TIME })
    end
  end

  module Verify
    def self.reset_password(token)
      return nil if token.nil?

      token_payload, token_header = JWT.decode(token, JWT_SECRET, true, { algorithm: 'HS256' })

      # check expiration time
      expiration_time = token_header['exp']
      return nil if expiration_time.nil?
      return nil if expiration_time < Time.now.to_i

      token_payload
    rescue JWT::DecodeError
      nil
    end
  end

end
