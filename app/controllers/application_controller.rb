class ApplicationController < ActionController::API

  #
  # App json code
  #
  def index
    @data = File.read("#{Rails.root}/public/index.json")
    @data = @data.gsub("ROOT/", root_url)
    @data = @data.gsub("FACEBOOK_ID", ENV['FACEBOOK_ID'])
    render json: @data
  end

  #
  # OAuth callback
  #
  # If facebook returns an authorization code
  # we can exchange it for an access token to be returned to the client app
  #
  def callback
    if !params[:error].blank?
      render json: { error: 'Error', message: params[:error] }, status: :bad_request
    else
      oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET'], callback_url)
      access_token = oauth.get_access_token(params[:code])

      graph = Koala::Facebook::API.new(access_token, ENV['FACEBOOK_SECRET'])
      profile = graph.get_object("me")

      pic = graph.get_picture_data(profile['id'], type: 'large')['data']['url']

      @user = User.find_or_create_by(fb_id: profile['id'])
      @user.update(fb_pic: pic, fb_name: profile['name'])

      redirect_to "jasonettefblogin://oauth?access_token=#{access_token}&token_type=bearer"
    end
  end

  protected
    #
    # Before filter to call on protected endpoints
    #
    def require_user
      render json: { error: 'Forbidden', message: 'You are not allowed to see this content' }, status: :forbidden if !current_user
    end

    #
    # Helper method to access token
    #
    def current_access_token
      params[:access_token]
    end

    #
    # Current user object validated via token, may be stored with expiration to avoid calls to facebook
    #
    def current_user
      if current_access_token
        profile = Koala::Facebook::API.new(current_access_token, ENV['FACEBOOK_SECRET']).get_object("me")
        User.where(fb_id: profile['id']).first
      end
    end
end
