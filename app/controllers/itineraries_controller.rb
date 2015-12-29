class ItinerariesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  before_action :set_itinerary, only: [:show]
  before_action :check_gender, only: [:show]

  before_action :check_permissions

  def new
    @itinerary = Itinerary.new
  end

  def index
    # @itineraries = Itinerary.includes(:user).all
  end

  def show
    @conversation = @itinerary.conversations.find_or_initialize_by(user_ids: [current_user.id, @itinerary.user.id]) if current_user
    @reference = current_user.references.find_or_initialize_by(itinerary_id: @itinerary.id) if current_user
    session[:redirect_to] = itinerary_path(@itinerary) unless user_signed_in?
  end

  def create
    @itinerary = current_user.itineraries.new(permitted_params.itinerary)
    if @itinerary.save
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.create') }
    else
      render :new
    end
  end

  def edit
    @itinerary = current_user.itineraries.find params[:id]
  end

  def update
    @itinerary = current_user.itineraries.find params[:id]
    if @itinerary.update_attributes permitted_params.itinerary
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.update') }
    else
      render :edit
    end
  end

  def destroy
    @itinerary = current_user.itineraries.find params[:id]
    @itinerary.destroy
    redirect_to itineraries_user_path(current_user), flash: { success: t('flash.itineraries.success.destroy') }
  end

  def search
    @itineraries = ItinerarySearch.new(params[:itineraries_search], current_user).itineraries
  end

  protected

  def check_permissions
  end

  def set_itinerary
    @itinerary = Itinerary.find params[:id]
  end

  def check_gender
    return unless @itinerary.pink?
    if !user_signed_in?
      redirect_to root_path
    elsif current_user.male?
      redirect_to :dashboard, flash: { error: t('flash.itineraries.error.pink') }
    end
  end
end
