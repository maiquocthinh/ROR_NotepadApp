# frozen_string_literal: true

module UserSessionManager
  def self.add_session(user_id, session_id)
    redis_session_key = get_redis_session_key(session_id)
    expire_in = get_expire_time_in(redis_session_key).to_i
    expire_at = Time.now.to_i + expire_in
    $redis.zadd(get_redis_user_sessions_key(user_id), expire_at, session_id)
    $redis.expire(get_redis_user_sessions_key(user_id), expire_in) if expire_in > 0

    remove_expired_sessions(user_id)
  end

  def self.get_sessions(user_id)
    session_ids = $redis.zrangebyscore(get_redis_user_sessions_key(user_id), Time.now.to_i, '+inf')
    redis_session_keys = session_ids.map { |session_id| get_redis_session_key(session_id) }

    sessions_data = $redis.mget(redis_session_keys)

    sessions_data.each_with_index.map do |session, index|
      session_data = Marshal.load(session)
      session_data.merge("session_id" => session_ids[index])
    end
  end

  def self.destroy_session(user_id, session_id)
    $redis.zrem(get_redis_user_sessions_key(user_id), session_id)
    $redis.del(get_redis_session_key(session_id))
  end

  private

  def self.remove_expired_sessions(user_id)
    $redis.zremrangebyscore(get_redis_user_sessions_key(user_id), 0, Time.now.to_i)
  end

  def self.get_redis_session_key(session_id)
    hashed_session_id = Digest::SHA256.hexdigest(session_id)
    "session:2::#{hashed_session_id}"
  end

  def self.get_redis_user_sessions_key(user_id)
    hashed_user_id = Digest::SHA256.hexdigest(user_id)
    "user:#{hashed_user_id}:sessions"
  end

  def self.get_expire_time_in(redis_key)
    ttl = $redis.ttl(redis_key)

    case ttl
    when -2
      default_expiry = Rails.application.config.session_options[:expire_after] || 24.hours
      default_expiry
    when -1
      Integer::INFINITY - Time.now.to_i
    else
      ttl
    end
  end

end
