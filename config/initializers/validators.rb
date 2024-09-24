# config/initializers/validators.rb
Dir[Rails.root.join('app/validators/**/*.rb')].each { |file| require file }