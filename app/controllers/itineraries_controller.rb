# frozen_string_literal: true

class ItinerariesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  before_action :set_itinerary, only: [:show]
  before_action :check_female, only: [:show]

  before_action :check_permissions

  def new
    @itinerary = Itinerary.new
  end

  def index
    # @itineraries = Itinerary.includes(:user).all
  end

  def show
    @conversation = @itinerary.conversations.find_or_initialize_by(sender: current_user, receiver: @itinerary.user) if current_user
    session[:redirect_to] = itinerary_path(@itinerary) unless user_signed_in?
  end

  def create
    @itinerary = current_user.itineraries.new(itinerary_params)
    if @itinerary.save
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.create') }
    else
      render :new
    end
  end

  def edit
    @itinerary = current_user.itineraries.friendly.find params[:id]
  end

  def update
    @itinerary = current_user.itineraries.friendly.find params[:id]
    if @itinerary.update itinerary_params
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.update') }
    else
      render :edit
    end
  end

  def destroy
    @itinerary = current_user.itineraries.friendly.find params[:id]
    @itinerary.destroy
    redirect_to itineraries_user_path(current_user), flash: { success: t('flash.itineraries.success.destroy') }
  end

  def search
    @itineraries = ItinerarySearch.new(params[:itineraries_search], current_user).itineraries
  end

  protected

  def check_permissions; end

  def set_itinerary
    @itinerary = Itinerary.friendly.find params[:id]
  end

  def itinerary_params
    params.require(:itinerary).permit(*itinerary_attributes)
  end

  def itinerary_attributes
    whitelist = %i[start_address end_address description num_people smoking_allowed pets_allowed fuel_cost tolls
                   avoid_highways avoid_tolls
                   round_trip leave_date return_date daily
                   route]
    whitelist << :pink if current_user&.female?
    whitelist
  end

  def check_female
    return unless @itinerary.pink?

    if !user_signed_in?
      redirect_to root_path
    elsif !current_user.female?
      redirect_to :dashboard, flash: { error: t('flash.itineraries.error.pink') }
    end
  end
end
