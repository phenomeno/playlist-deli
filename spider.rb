require 'httparty'
require 'nokogiri'
require 'rspotify'

RSpotify::authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])

PLAYLIST_SEQ_ID = 431978040
MELON_PLAYLIST_URL = "http://www.melon.com/mymusic/dj/mymusicdjplaylistview_listSong.htm?plylstSeq="

playlist_url = "#{MELON_PLAYLIST_URL}#{PLAYLIST_SEQ_ID}"
response = HTTParty.get(playlist_url)
body = response.body
doc = Nokogiri::HTTP(body)
trs = doc.css('tr')[1..-1]

tracks = []
trs.each do |tr|
  tracks << tr.css('td > div > div > a').map(&:text)[1, 2]
end

spotify_tracks = []
tracks.each do |track|
  spotify_tracks << RSpotify::Track.search(track.join(" ")).first
end
