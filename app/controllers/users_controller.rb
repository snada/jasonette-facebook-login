class UsersController < ApplicationController
  before_action :require_user

  #
  # Protected endpoint example:
  #
  # The require_user before action will render a forbidden message if no valid access token is provided
  #
  def show
    render json: {
      name: current_user.fb_name,
      pic: current_user.fb_pic
    }
  end
end
