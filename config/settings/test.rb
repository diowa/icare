# frozen_string_literal: true
# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  group :itineraries do
    group :bounds do
      set :sw, [2, 5]
      set :ne, [4, 7]
    end
  end
end
