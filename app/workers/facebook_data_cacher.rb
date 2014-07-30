class FacebookDataCacher
  @queue = :facebook_cache_data_queue

  def self.perform(user_id)
    user = User.find user_id
    if user.facebook_data_cached_at < APP_CONFIG.facebook.cache_expiry_time.ago.utc
      if user.cache_facebook_data?
        user.update_attribute :facebook_data_cached_at, Time.now.utc
      else
        # TODO: add to task rescheduling list
      end
    end
  end
end
