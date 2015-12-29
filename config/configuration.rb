SimpleConfig.for :application do
  # Set here your global configuration.
  # All settings can be overwritten later per-environment.
  load File.join(Rails.root.to_s, 'config', 'settings', 'application.rb'),   if_exists?: true

  # Per Environment settings.
  # At startup only the file matching current environment will be loaded.
  # Settings stored here will overwrite settings with the same name stored in application.rb
  load File.join(Rails.root.to_s, 'config', 'settings', "#{Rails.env}.rb"),  if_exists?: true

  # Local settings. It is designed as a place for you to override variables
  # specific to your own development environment.
  # Make sure your version control system ignores this file otherwise
  # you risk checking in a file that will override values in production
  load File.join(Rails.root.to_s, 'config', 'settings', 'local.rb'),         if_exists?: true
end

APP_CONFIG = SimpleConfig.for :application
