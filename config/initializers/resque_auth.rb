Resque::Server.use(Rack::Auth::Basic) do |user_name, password|
  user_name == APP_CONFIG.resque.user_name
  password == APP_CONFIG.resque.password
end
