# From Diaspora

worker_processes 3
timeout 30
preload_app true

@resque_pid = nil

before_fork do |_server, _worker|
  unless APP_CONFIG.single_process_mode
    if defined?(Resque) && defined?(Redis)
      # Clean up Resque workers killed by previous deploys/restarts
      Resque.workers.each(&:unregister_worker)
      @resque_pid ||= spawn('bundle exec rake resque:work QUEUE=*')

      # disconnect redis if in use
      Resque.redis.client.disconnect
    end
  end
end

after_fork do |_server, _worker|
  unless APP_CONFIG.single_process_mode
    if defined?(Resque) && defined?(Redis)
      Resque.redis = Redis.new(url: APP_CONFIG.redis.url)
    end
  end
end
