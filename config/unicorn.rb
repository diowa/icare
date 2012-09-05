worker_processes 3
timeout 30
preload_app true

before_fork do |server, worker|
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|
  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = APP_CONFIG.redis.url
    Rails.logger.info('Connected to Redis')
  end
end
