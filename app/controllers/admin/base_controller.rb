class Admin::BaseController < ApplicationController
  before_filter :check_admin
end
