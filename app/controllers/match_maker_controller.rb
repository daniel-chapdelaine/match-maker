class MatchMakerController < ApplicationController
  def new
    matchMaker = MatchMaker.new('Obie')
    @name = matchMaker.name 
    @scores = matchMaker.ranked_scores 
  end

end
