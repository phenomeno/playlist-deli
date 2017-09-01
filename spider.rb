require_relative './app'

RSpotify::authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])

PLAYLIST_SEQ_ID = 431978040
MELON_PLAYLIST_URL = "http://www.melon.com/mymusic/dj/mymusicdjplaylistview_listSong.htm?plylstSeq="

playlist_url = "#{MELON_PLAYLIST_URL}#{PLAYLIST_SEQ_ID}"
response = HTTParty.get(playlist_url)
body = response.body
doc = Nokogiri::HTML(body)
trs = doc.css('tr')[1..-1]

tracks = []
trs.each do |tr|
  tracks << tr.css('td > div > div > a').map(&:text)[1, 2]
end

spotify_tracks = []
tracks.each do |track|
  puts track
  spotify_tracks << RSpotify::Track.search(track.join(" ")).first
end

user_hash = JSON.parse(File.read('credentials.json'))
spotify_user = RSpotify::User.new(user_hash)
playlist = spotify_user.create_playlist!('Melon Hiphop/EDM')
playlist.add_tracks!(spotify_tracks.compact)

puts 'added'
