class ItinerariesController < ApplicationController

  skip_before_filter :check_admin, only: [:index]
  skip_before_filter :require_login, only: [:index, :show, :search]

  before_filter :check_gender, only: [:show]

  before_filter :check_permissions
  # TODO proper edit methods

  def new
    @itinerary = Itinerary.new
  end

  def index
    #@itineraries = Itinerary.includes(:user).all
  end

  def mine
    @itineraries = current_user.itineraries
  end

  def show
    @conversation = @itinerary.conversations.find_or_initialize_by(user_ids: [current_user.id, @itinerary.user.id]) if current_user
    @reference = @itinerary.user.references.find_or_initialize_by(referencing_user: current_user) if current_user
  end

  def create
    @itinerary = Itinerary.build_with_route_json_object(params[:itinerary], current_user)
    if @itinerary.save
      redirect_to itinerary_path(@itinerary)
    else
      render :new
    end
  end

  def edit
    @itinerary = current_user.itineraries.find(params[:id])
  end

  def update
    @itinerary = current_user.itineraries.find(params[:id])
    if @itinerary.update_attributes(params[:itinerary])
      redirect_to my_itineraries_path, flash: { success: t('flash.itinerary.success.update') }
    else
      render :edit
    end
  end

  def destroy
    @itinerary = current_user.itineraries.find(params[:id])
    if @itinerary.destroy
      redirect_to my_itineraries_path, flash: { success: t('flash.itinerary.success.destroy') }
    else
      redirect_to my_itineraries_path, flash: { error: t('flash.itinerary.error.destroy') }
    end
  rescue
    redirect_to my_itineraries_path, flash: { error: t('flash.itinerary.error.destroy') }
  end

  def search
    respond_to do |format|
      format.json do
        if request.xhr?
          @itineraries = Itinerary.search(params[:itinerary_search], current_user.male?)
        else
          redirect_to root_path
        end
      end
      format.html do
        render(layout: false , json: {success: true,
                                      data: Itinerary.all.as_json(except: [:deleted_at,
                                                                           :overview_path]) })
      end
    end
  end

protected

  def check_permissions
  end

  def check_gender
    @itinerary = Itinerary.find(params[:id])
    return unless @itinerary.pink?
    if !logged_in?
      redirect_to root_path
    elsif current_user.male?
      redirect_to :dashboard, flash: { error: t('flash.itinerary.error.pink') }
    end
  end
end
