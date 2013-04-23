class ItinerariesController < ApplicationController

  skip_before_filter :require_login, only: [:show, :search]

  before_filter :check_gender, only: [:show]

  before_filter :check_permissions

  def new
    @itinerary = Itinerary.new
    @itinerary_route = Itineraries::Route.new
  end

  def index
    #@itineraries = Itinerary.includes(:user).all
  end

  def show
    @conversation = @itinerary.conversations.find_or_initialize_by(user_ids: [current_user.id, @itinerary.user.id]) if current_user
    @reference = current_user.references.find_or_initialize_by(itinerary_id: @itinerary.id) if current_user
    session[:redirect_to] = itinerary_path(@itinerary) unless logged_in?
  end

  def create
    @itinerary = ItineraryBuild.new(permitted_params.itinerary, current_user).itinerary
    if @itinerary.save
      redirect_to itinerary_path(@itinerary), flash: { success: t('flash.itineraries.success.create') }
    else
      @itinerary_route = Itineraries::Route.new params[:itinerary][:itineraries_route]
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
    if @itinerary.destroy
      redirect_to itineraries_user_path(current_user), flash: { success: t('flash.itineraries.success.destroy') }
    else
      redirect_to itineraries_user_path(current_user), flash: { error: t('flash.itineraries.error.destroy') }
    end
  rescue
    redirect_to itineraries_user_path(current_user), flash: { error: t('flash.itineraries.error.destroy') }
  end

  def search
    @itineraries = ItinerarySearch.new(params[:itineraries_search], current_user).itineraries
  end

  protected
  def check_permissions
  end

  def check_gender
    @itinerary = Itinerary.find params[:id]
    return unless @itinerary.pink?
    if !logged_in?
      redirect_to root_path
    elsif current_user.male?
      redirect_to :dashboard, flash: { error: t('flash.itineraries.error.pink') }
    end
  end
end
