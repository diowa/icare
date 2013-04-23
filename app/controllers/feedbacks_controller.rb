class FeedbacksController < ApplicationController

  before_filter :check_owner_or_admin, only: [:edit, :update, :destroy]

  def index
    @feedbacks = Feedback.includes(:user).all.desc(:updated_at).page params[:page]
    @feedbacks = @feedbacks.where(:status.ne => 'fixed') if params[:hide_fixed]
    @url = request.env['HTTP_REFERER']
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def new
    @feedback = Feedback.new(url: params[:url])
  end

  def create
    @feedback = current_user.feedbacks.build(permitted_params.feedback)
    if @feedback.save
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.create') }
    else
      flash.now[:error] = @feedback.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @feedback.update_attributes(permitted_params.feedback)
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.update') }
    else
      flash.now[:error] = @feedback.errors.full_messages
      render :edit
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    if @feedback.destroy
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.destroy') }
    else
      redirect_to feedbacks_path, flash: { error: t('flash.feedbacks.error.destroy') }
    end
  end

  private
  def check_owner_or_admin
    @feedback = Feedback.find(params[:id])
    redirect_to :dashboard, flash: { error: t('flash.errors.not_allowed') } unless current_user.admin? || current_user == @feedback.user
  end
end
