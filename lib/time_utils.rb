# frozen_string_literal: true

module TimeUtils
  PERIODS = {
    year: 365 * 30 * 24 * 60 * 60 * 1000,
    month: 30 * 24 * 60 * 60 * 1000,
    week: 7 * 24 * 60 * 60 * 1000,
    day: 24 * 60 * 60 * 1000,
    hour: 60 * 60 * 1000,
    minute: 60 * 1000
  }.freeze

  private_constant :PERIODS

  def self.calculate_elapsed_time(time_created)
    created = time_created.to_time.to_f * 1000
    diff = Time.now.to_f * 1000 - created

    PERIODS.each do |key, value|
      if diff >= value
        result = (diff / value).floor
        return "#{result} #{key}#{'s' if result > 1} ago"
      end
    end

    'Just now'
  end
end
