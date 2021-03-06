class LyricsSetsController < ApplicationController
  before_action :set_lyrics_set, only: [:show, :update, :destroy]
  before_action :find_first_or_create, only: [:get_lyrics_sets, :create, :get_most_liked_lyrics_set]

  # GET /posts
  # GET /posts.json
  def index
    if params[:song_id].present?
      @lyrics_sets = LyricsSet.where(:song_id => params[:song_id]).visible.sortedByVotes
    else
      #should is for testing only
      @lyrics_sets = LyricsSet.all.sortedByVotes
    end

    if params[:user_id].present?
      render json: @lyrics_sets, :user => User.find(params[:user_id])
    else
      render json: @lyrics_sets
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    #show the entire content
    render json: @lyrics_set, serializer: LyricsSetContentSerializer
  end

 # POST /lyrics_sets
  def create
    if @song.nil?
      render json: { error: "Invalid parameters" }, status: 422
    else
      found_lyrics_set = LyricsSet.where(song_id: @song.id, user_id: params[:user_id]).first
      if found_lyrics_set.present?
        found_lyrics_set.update_attributes(:times => params[:times], :lyrics => params[:lyrics],
        :last_edited => Time.now, :visible => params[:visible])
        render json: found_lyrics_set
      else
        @lyrics_set = LyricsSet.new(:times => params[:times], :lyrics => params[:lyrics],
          :song_id => @song.id, :user_id => params[:user_id], :last_edited => Time.now, :visible => params[:visible])
        if @lyrics_set.save
          render json: @lyrics_set, status: :created, location: @lyrics_set
        else
          render json: @lyrics_set.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE lyrics_sets/:id
  def destroy
    @lyrics_set.destroy
    if @lyrics_set.destroyed?
      render json: { result: "successfully destroyed"}
    else
      render json: { result: "cannot destroy"}
    end
  end

  # GET server/get_most_liked_lyrics_set
  def get_most_liked_lyrics_set
    if @song.nil?
        render json: { error: "Invalid parameters" }, status: 422
    else
      most_liked_set = @song.lyrics_sets.visible.sortedByVotes.first
      if most_liked_set.present?
        render json: @song.lyrics_sets.visible.sortedByVotes.first, serializer: LyricsSetContentSerializer
      else
        render json: { error: "not-found"}, status: 404
      end
    end
  end


  # GET server/get_lyrics_sets
  def get_lyrics_sets
    if @song.nil?
      render json: { error: "Invalid parameters" }, status: 422
    else
      if params[:user_id].present?
        render json: @song.lyrics_sets.visible.sortedByVotes, :user => User.find(params[:user_id])
      else
        render json: @song.lyrics_sets.visible.sortedByVotes
      end
    end
  end

  #PUT /lyrics_sets/:id/change_visibility
   def change_visibility
     set = LyricsSet.find(params[:id])
     if set.visible
       set.visible = false
     else
       set.visible = true
     end
     set.save
     render json: set
   end

  #PUT /lyrics_sets/:id/like  body: { "user_id": id}
  def upvote
    set = LyricsSet.find(params[:id])
    current_user = User.find(params[:user_id])
    if current_user.voted_up_on? set #if this user already voted, remove the vote
      set.unliked_by current_user
    else
      set.upvote_by current_user
    end
    render json: set, :user => current_user
  end

  #PUT /lyrics_sets/:id/dislike  body: { "user_id": id}
  def downvote
    set = LyricsSet.find(params[:id])
    current_user = User.find(params[:user_id])
    if current_user.voted_down_on? set #if this user already voted, remove the vote
      set.undisliked_by current_user
    else
      set.downvote_by current_user
    end
    render json: set, :user => current_user
  end

  private
  def set_lyrics_set
    @lyrics_set = LyricsSet.find(params[:id])
  end

  def save_and_render
    if @lyrics_set.save
      render json: @lyrics_set, status: :created, location: @lyrics_set
    else
      render json: @lyrics_set.errors, status: :unprocessable_entity
    end
  end
end
