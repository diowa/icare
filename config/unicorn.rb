# From Diaspora

worker_processes 3
timeout 30
preload_app true

@resque_pid = nil

before_fork do |server, worker|
  unless APP_CONFIG.single_process_mode
    # Clean up Resque workers killed by previous deploys/restarts
    Resque.workers.each { |w| w.unregister_worker }
    @resque_pid ||= spawn('bundle exec rake resque:work QUEUE=*')
  end

  # disconnect redis if in use
  unless APP_CONFIG.single_process_mode
    Resque.redis.client.disconnect
  end
end

after_fork do |server, worker|
  # copy pasta from resque.rb because i'm a bad person
  unless APP_CONFIG.single_process_mode
    uri = URI.parse(APP_CONFIG.redis.url)
    REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    Resque.redis = REDIS if defined?(Resque)
  end
end
