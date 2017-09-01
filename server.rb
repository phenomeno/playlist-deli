require_relative './app'

require 'sinatra'
enable :run

get '/' do
  erb "<a href='/auth/spotify'>Sign in with Spotify</a>"
end

get '/auth/spotify/callback' do
  spotify_user = RSpotify::User.new(request.env['omniauth.auth']).to_hash

  File.write('credentials.json', spotify_user.to_json)

  "ok tokki"
end
