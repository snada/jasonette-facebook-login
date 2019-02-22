require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET me' do
    let(:fb_user_id) { 1000 }
    let(:access_token) { 'token' }
    let(:appsecret_proof) {
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        ENV['FACEBOOK_SECRET'],
        access_token
      )
    }

    before(:each) do
      FactoryBot.create(:user, fb_id: fb_user_id)

      stub_request(:get, "https://graph.facebook.com/me?access_token=#{access_token}&appsecret_proof=#{appsecret_proof}").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.15.4'}).
        to_return(status: 200, body: %Q{{"name": "User Name","id": "#{fb_user_id}"}})
    end

    it 'should return user data with access token in params' do
      process :show, params: { access_token: access_token }

      expect(response).to have_http_status(:ok)
    end

    it 'should return user data with access token in authorization header' do
      @request.env['HTTP_AUTHORIZATION'] = "Bearer #{access_token}"
      process :show

      expect(response).to have_http_status(:ok)
    end

    it 'should return an error when an access token is not present' do
      process :show

      expect(response).to have_http_status(:forbidden)
    end
  end
end
