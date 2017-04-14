# frozen_string_literal: true

class CacheFacebookDataJob < ApplicationJob
  queue_as :cache_facebook_data_queue

  def perform(user)
    if user.facebook_data_cached_at < APP_CONFIG.facebook.cache_expiry_time.ago.utc
      user.update_facebook_data!
    else
      false
    end
  end
end
