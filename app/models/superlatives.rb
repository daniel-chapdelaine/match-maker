require 'benchmark'

class Superlatives

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
      most_firsts: most_firsts,
      most_lasts: most_lasts,
      # most_fire_selections: [],
      # most_ice_selections: []
    }
  end

  def most_firsts
    most_matches(@is_best)
  end

  def most_lasts
    most_matches(@is_worst)
  end

  def highest_points_scored 
    top_two_scores = get_top_two_cards(@is_best)
    dedup(top_two_scores)
  end

  def lowest_points_scored 
    top_two_scores = get_top_two_cards(@is_worst)
    dedup(top_two_scores)
  end

  
  def most_matches(list)
    scores = {}
    list.each do |item| 
      if scores[item[:match]]
        scores[item[:match]] += 1
      else
        scores[item[:match]] = 1
      end
    end
    score_cards = scores.map {|key, value|  { name: key, score: value }}
    sort(score_cards)
    return get_top_two_cards(score_cards)
  end

  def is_best_and_is_worst
    @all_ranked_matches.each do |rankings|
      name = rankings[:name]
      rankings[:ranked_matches].each do |ranked_match| 
        @is_best << get_score_card(name, ranked_match) if ranked_match[:is_best]    
        @is_worst << get_score_card(name, ranked_match) if ranked_match[:is_worst]
        # @is_hot << get_score_card(name, ranked_match) if ranked_match[:is_hot]
        # @is_warm << get_score_card(name, ranked_match) if ranked_match[:is_warm]
        # @is_cold << get_score_card(name, ranked_match) if ranked_match[:is_cold]
      end
    end
    sort(@is_best)
    sort(@is_worst).reverse!
  end

  def dedup(list)
    final = []
    list.each do |rank| 
      if final.first.nil? 
        final << rank 
      else
        already_added = false
        final.each do |score| 
          already_added = score[:pair].sort! == rank[:pair].sort!
          break if already_added
        end
        final << rank if !already_added
      end
    end
    return final
  end 

  def get_top_two_cards(ranked)
    scores = ranked.map { |rank| rank[:score] }.uniq
    first = scores.first
    second = scores.second
    top_two = []
    ranked.each do |rank| 
      if rank[:score] == first || rank[:score] == second
        top_two << rank 
      end
    end
    return top_two
  end 

  def sort(arr)
    arr.sort! { |a, b|  b[:score] <=> a[:score] }
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

