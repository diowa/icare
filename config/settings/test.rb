# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  group :itineraries do
    set :geo_restricted, false
    group :bounds do
      # Needed by test specs
      set :sw, [2, 5]
      set :ne, [4, 7]
    end
  end
end
