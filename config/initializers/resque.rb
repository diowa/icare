uri = URI.parse(APP_CONFIG.redis.url)
REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Resque.redis = REDIS if defined?(Resque)

# Web interface
if defined?(Resque::Server)
  Resque::Server.use(Rack::Auth::Basic) do |user_name, password|
    user_name == APP_CONFIG.resque.user_name
    password == APP_CONFIG.resque.password
  end
end
