class FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_admin, only: [:edit, :update, :destroy]

  def index
    @feedbacks = Feedback.includes(:user).all.desc(:updated_at).page params[:page]
    @feedbacks = @feedbacks.where(:status.ne => 'fixed') if params[:hide_fixed]
    @url = request.env['HTTP_REFERER']
  end

  def new
    @feedback = Feedback.new(url: params[:url])
  end

  def create
    @feedback = current_user.feedbacks.build(permitted_params.feedback)
    if @feedback.save
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.create') }
    else
      render :new
    end
  end

  def update
    if @feedback.update_attributes(permitted_params.feedback)
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.update') }
    else
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.destroy') }
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def check_owner_or_admin
    redirect_to :dashboard, flash: { error: t('flash.errors.not_allowed') } unless current_user.admin? || current_user == @feedback.user
  end
end
