# frozen_string_literal: true

# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  group :itineraries do
    set :bounds, [
      [5, 4],
      [7, 4],
      [2, 7],
      [2, 5]
    ]
  end
end
