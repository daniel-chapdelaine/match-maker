class SuperlativesController < ApplicationController

  def submit 
    @include_pcs = params['include_pcs'] == '1'
    @include_people = params['include_people'] == '1'
    @include_extended_sections = params['include_extended_sections'] == '1'
    @superlatives = Superlatives.new.build()
  end
end
