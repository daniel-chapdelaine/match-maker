require 'benchmark'

class Superlatives

# build every participant 
# most times first, most times last, most selections made, least selctions
  def initialize
    @is_best = []
    @is_worst = []
  end

  # should i pass any params??
  def build(include_pcs = true, include_people = true, include_extended_sections = true)
    all_names = MatchMaker.new('').all_names
    all_match_makers = all_names.map do |name| 
      MatchMaker.new(name, include_pcs, include_people, include_extended_sections)
    end
    @all_ranked_matches = all_match_makers.map do |match_maker| 
      match_maker.set_match_makers_list(all_match_makers)
      {name: match_maker.name, ranked_matches: match_maker.ranked_matches}  
    end

    is_best_and_is_worst

    final
  end

  def benchmark_build(include_pcs = true, include_people = true, include_extended_sections = true)
    time = Benchmark.measure do
      build(include_pcs = false, include_people = false, include_extended_sections = false)
    end
    puts time.real
  end

  def final 
    {
      highest_points_scored: highest_points_scored,
      lowest_points_scored: lowest_points_scored,
      most_firsts: [],
      most_lasts: [],
      most_selections: [],
      least_selections: [],
      most_fire_selections: [],
      most_ice_selections: []
    }
  end

  def highest_points_scored 
    get_top_two(@is_best)
  end

  def lowest_points_scored 
    get_top_two(@is_worst)
  end

  def is_best_and_is_worst
    @all_ranked_matches.each do |rankings|
      name = rankings[:name]
      rankings[:ranked_matches].each do |ranked_match| 
        @is_best << get_score_card(name, ranked_match) if ranked_match[:is_best_match]    
        @is_worst << get_score_card(name, ranked_match) if ranked_match[:is_worst_match]
      end
    end
    @is_best.sort! { |a, b|  b[:score] <=> a[:score] }
    @is_worst.sort! { |a, b|  b[:score] <=> a[:score] }.reverse!
  end

  def get_top_two(ranked)
    top_two = []
    ranked.each do |rank| 
      break if top_two.map { |top| top[:score] }.uniq.count == 2
      if top_two.first.nil? 
        top_two << rank 
      else
        already_added = false
        top_two.each { |top| already_added = top[:pair].sort! == rank[:pair].sort! }
        top_two << rank if !already_added
      end
    end
    return top_two
  end 

  def get_score_card(name, match)
    {
      name: name,
      match: match[:name], 
      pair: [ name, match[:name] ],
      score: match[:score]
    }
  end

end

