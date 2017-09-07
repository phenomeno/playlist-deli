module PlaylistDeli
  module Tasks
    class Sampler

      attr_reader :user, :artists, :playlists, :new_tracks, :processed_tracks

      def initialize(user)
        RSpotify::authenticate(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
        @user = user
      end

      def create_new_mix!(type)
        @artists = artists_by_type(type)
        @playlists = playlists_by_artists(@artists)
        @new_tracks = sample_tracks_from_playlists(@playlists)
        @processed_tracks = remove_dupes!(@new_tracks)

        name = "#{Time.now.strftime('%Y-%m-%d %H:%M')} Mix"
        playlist = user.create_playlist!(name)
        playlist.add_tracks!(@processed_tracks)

        name
      end

      def artist_in_playlist?(playlist, artist_id)
        playlist.tracks.flat_map(&:artists).any? { |x| x.id == artist_id }
      end

      def remove_dupes!(tracks)
        ids = tracks.map(&:id)
        deleted = []
        tracks.delete_if do |track|
          count = ids.select { |id| id == track.id }.count
          count > 1 && !deleted.include?(track.id)
        end

        tracks.shuffle
      end

      def recent_artists
        tracks = user.saved_tracks
        tracks.flat_map(&:artists)
      end

      def top_artists(time_range)
        user.top_artists(time_range: time_range)
      end

      def artists_by_type(type)
        if type == 'recent'
          recent_artists
        elsif type == 'long_term'
          top_artists(type)
        elsif type == 'medium_term'
          top_artists(type)
        elsif type == 'short_term'
          top_artists(type)
        else
          nil
        end
      end

      def playlists_by_artists(artists)
        playlists = {}
        artists.each do |artist|
          playlists[artist.id] = RSpotify::Playlist.search(artist.name)
        end

        playlists
      end

      def sample_tracks_from_playlists(playlists)
        new_tracks = []
        playlists.each do |artist_id, playlist_array|
          sorted = playlist_array.select { |x| x.total > 10 }
          if sorted.count > 1
            sorted = sorted.sort_by { |x| x.total }
          else
            sorted = sorted.sort_by { |x| -x.total }
          end
          next if sorted.first.total == 1
          print '.'

          sorted.each do |playlist|
            next unless artist_in_playlist?(playlist, artist_id)
            new_tracks += playlist.tracks.sample(2)
            break
          end
        end

        new_tracks
      end

    end
  end
end
