class FacebookDataCacher
  @queue = :facebook_cache_data_queue

  def self.perform(user_id)
    user = User.find user_id
    if user.facebook_data_cached_at < APP_CONFIG.facebook.cache_expiry_time.ago.utc
      # TODO: add to task rescheduling list
      if user.cache_facebook_data?
        user.update_attribute :facebook_data_cached_at, Time.now.utc
      end
    end
  end
end
