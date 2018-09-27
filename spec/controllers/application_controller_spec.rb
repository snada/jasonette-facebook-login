require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'routes to index' do
      expect(get: '/').to route_to(controller: 'application', action: 'index')
    end
  end

  describe 'GET index' do
    it 'should render a JSON jasonette app' do
      process :index, method: :get

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['$jason']).not_to be_nil
    end
  end

  describe 'GET callback' do
    let(:fb_user_id) { 1000 }
    let(:code) { 'code' }
    let(:access_token) { 'token' }
    let(:appsecret_proof) {
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        ENV['FACEBOOK_SECRET'],
        access_token
      )
    }

    before(:each) do
      stub_request(:get, "https://graph.facebook.com/oauth/access_token?client_id=#{ENV['FACEBOOK_ID']}&client_secret=#{ENV['FACEBOOK_SECRET']}&code=#{code}&redirect_uri=#{root_url}callback")
        .with(headers: { 'Accept': '*/*', 'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.15.3'})
        .to_return(status: 200, body: "access_token=#{access_token}&expires=5105445")

      stub_request(:get, "https://graph.facebook.com/me?access_token=#{access_token}&appsecret_proof=#{appsecret_proof}").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return(status: 200, body: %Q{{"name": "User Name","id": "#{fb_user_id}"}})

      stub_request(:get, "https://graph.facebook.com/#{fb_user_id}/picture?access_token=#{access_token}&appsecret_proof=#{appsecret_proof}&redirect=false&type=large").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return(status: 200, body: %Q{{"data": { "is_silhouette": false, "url": "https://upload.wikimedia.org/wikipedia/commons/a/ab/Lolcat_in_folder.jpg"}}})
    end

    it 'should redirect to jasonette app returning an access token' do
      process :callback, method: :get, params: { code: code }

      expect(response).to redirect_to("jasonettefblogin://oauth?access_token=#{access_token}&token_type=bearer")
    end

    it 'should render some error the callback is called with error parameters in it' do
      process :callback, method: :get, params: { error: 'This is an error' }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
