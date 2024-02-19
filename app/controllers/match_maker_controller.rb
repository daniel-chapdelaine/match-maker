class MatchMakerController < ApplicationController
  def new
    matchMaker = MatchMaker.new('')
    @all_names = matchMaker.all_names
    @name = @all_names.first
    @include_pcs = true
    @include_people = false
    @include_extended_sections = false
  end

  def submit
    @name = params['name']
    @include_pcs = params['include_pcs'] == '1'
    @include_people = params['include_people'] == '1'
    @include_extended_sections = params['include_extended_sections'] == '1'
    matchMaker = MatchMaker.new(
      @name,
      @include_pcs,
      @include_people, 
      @include_extended_sections
    )
    @all_names = matchMaker.all_names
    @matches = matchMaker.ranked_matches 
    render 'submit'
  end


end
