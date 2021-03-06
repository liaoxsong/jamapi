class LyricsSetContentSerializer < ActiveModel::Serializer
  attributes :id, :cached_votes_score, :times, :lyrics, :song_id, :user_id, :number_of_lines,
   :lyrics_preview, :visible, :last_edited
   has_one :song, serializer: SongInformationSerializer
end
