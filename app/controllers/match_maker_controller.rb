class MatchMakerController < ApplicationController
  def new
    matchMaker = MatchMaker.new('')
    @all_names = matchMaker.all_names

  end

  def submit
    matchMaker = MatchMaker.new(params['name'])
    @all_names = matchMaker.all_names
    @name = matchMaker.name 
    @scores = matchMaker.ranked_scores 
    render 'submit'
  end

end
