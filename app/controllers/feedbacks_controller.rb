# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :set_feedback, only: %i[show edit update destroy]
  before_action :check_owner_or_admin, only: %i[edit update destroy]

  helper_method :feedback_attributes

  def index
    @feedbacks = Feedback.includes(:user).order(updated_at: :desc).page params[:page]
    @feedbacks = @feedbacks.where(:status.ne => 'fixed') if params[:hide_fixed]
    @url = request.env['HTTP_REFERER']
  end

  def show; end

  def new
    @feedback = Feedback.new(url: params[:url])
  end

  def edit; end

  def create
    @feedback = current_user.feedbacks.build(feedback_params)
    if @feedback.save
      redirect_to feedbacks_path, flash: { success: t('flash.feedbacks.success.create') }
    else
      render :new
    end
  end

  def update
    if @feedback.update(feedback_params)
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

  def feedback_params
    params.require(:feedback).permit(*feedback_attributes)
  end

  def feedback_attributes
    whitelist = %i[category message url]
    whitelist << :status if current_user&.admin?
    whitelist
  end

  def check_owner_or_admin
    redirect_to :dashboard, flash: { error: t('flash.errors.not_allowed') } unless current_user.admin? || current_user == @feedback.user
  end
end
