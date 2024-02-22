require 'benchmark'

class Superlatives

# build every participant 
# access highest points pair, lowest points pair, most times first, most times last, most selections made, least selctions

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
    # {
    #   highest_points_scored: get_highest_points_scored,
    #   lowest_points_scored: [],
    #   most_firsts: [],
    #   most_lasts: [],
    #   most_selections: [],
    #   least_selections: [],
    #   most_fire_selections: [],
    #   most_ice_selections: []
    # }

    get_highest_points_scored
  end

  def benchmark_build(include_pcs = true, include_people = true, include_extended_sections = true)
    time = Benchmark.measure do
      build(include_pcs = false, include_people = false, include_extended_sections = false)
    end
    puts time.real
  end


  def get_highest_points_scored
    is_best = []
    @all_ranked_matches.each do |rankings|
      name = rankings[:name]
      rankings[:ranked_matches].each do |ranked_match| 
        if ranked_match[:is_best_match]
          is_best << {winners: [name, ranked_match[:name]], score: ranked_match[:score]}
        end
      end
    end
    ranked = is_best.sort! { |a, b|  b[:score] <=> a[:score] }
    top_two = []
    ranked.each do |rank| 
      break if top_two.count == 2
      top_two << rank if top_two.first.nil? 
      top_two << rank if top_two.first[:winners].sort! != rank[:winners].sort!
    end
    top_two
  end

end

