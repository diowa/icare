# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  group :facebook do
    set :restricted_group_id, nil
  end

  group :itineraries do
    set :geo_restricted, false
    group :bounds do
      set :sw, [2, 5]
      set :ne, [4, 7]
    end
  end
end
