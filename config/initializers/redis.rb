uri = URI.parse(APP_CONFIG.redis.url)
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Resque.redis = REDIS if defined?(Resque)
