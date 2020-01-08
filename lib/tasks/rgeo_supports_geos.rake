# frozen_string_literal: true

desc 'Check if RGeo supports GEOS'
task rgeo_supports_geos: :environment do
  abort 'Error: RGeo does not support GEOS extensions.' unless RGeo::Geos.supported?
end
