=begin
class Itineraries::BuildController < ApplicationController
  include Wicked::Wizard

  steps :details, :confirm_and_share

  def show
    @itinerary = Itinerary.find(params[:itinerary_id])
    render_wizard
  end

  def update
    @itinerary = Itinerary.find(params[:itinerary_id])
    @itinerary.update_attributes(params[:itinerary])
    render_wizard @itinerary
  end

  def create
    @itinerary = Itinerary.create
    redirect_to wizard_path(steps.first, itinerary_id: @itinerary.id)
  end
end
=end
