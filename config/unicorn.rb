# Code borrowed from Diaspora

worker_processes 3
timeout 30
preload_app true

@resque_pid = nil

unless APP_CONFIG.single_process_mode
  if defined?(Resque) && defined?(Redis)
    before_fork do |server, worker|
      # Clean up Resque workers killed by previous deploys/restarts
      Resque.workers.each { |w| w.unregister_worker }
      @resque_pid ||= spawn('bundle exec rake resque:work QUEUE=*')

      # disconnect Redis if in use
      Resque.redis.client.disconnect
    end

    after_fork do |server, worker|
      Resque.redis = Redis.new(url: APP_CONFIG.redis.url)
    end
  end
end
