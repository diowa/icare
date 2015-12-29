class CacheFacebookDataJob < ActiveJob::Base
  queue_as :cache_facebook_data_queue

  def perform(user_id)
    user = User.find user_id
    user.cache_facebook_data! if user.facebook_data_cached_at < APP_CONFIG.facebook.cache_expiry_time.ago.utc
  end
end
