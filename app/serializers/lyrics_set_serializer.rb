class LyricsSetSerializer < ActiveModel::Serializer
  attributes :id, :cached_votes_score, :number_of_lines,
   :lyrics_preview, :vote_status, :last_edited, :song_id, :visible

  has_one :song, serializer: SongInformationSerializer
  has_one :user, serializer: UserListSerializer

  def vote_status
    if options[:user] == nil
      return "no user applicable"
    else
      if options[:user].voted_up_on? object
        return "up"
      elsif options[:user].voted_down_on? object
        return "down"
      else
        return "yet"
      end
    end
  end

end
