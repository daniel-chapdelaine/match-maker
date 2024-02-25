require 'benchmark'

class Superlatives

  def initialize
    @is_best = []
    @is_worst = []
    @is_hot = []
    @is_warm = []
    @is_cold = []
  end

  def build(include_pcs = true, include_people = true, include_extended_sections = true)
    names = MatchMaker.new('').all_names.map do |name|
      next if MatchMaker::PC_NAMES.include?(name) && !include_pcs
      next if MatchMaker::PEOPLE_NAMES.include?(name) && !include_people
      name
    end.compact

    all_match_makers = names.map do |name| 
      MatchMaker.new(name, include_pcs, include_people, include_extended_sections)
    end

    @all_ranked_matches = all_match_makers.map do |match_maker| 
      match_maker.set_match_makers_list(all_match_makers)
      {name: match_maker.name, ranked_matches: match_maker.ranked_matches}  
    end

    sort_rankings

    final
  end

  def benchmark_build(include_pcs = true, include_people = true, include_extended_sections = true)
    time = Benchmark.measure do
      build(include_pcs = false, include_people = false, include_extended_sections = false)
    end
    puts time.real
  end

  def final 
    [
      highest_points_scored,
      lowest_points_scored,
      most_firsts,
      most_lasts,
      most_hot,
      most_warm,
      most_cold,
    ]
  end

  def most_hot
    winners, runnersup = most_matches(@is_hot).partition { |x| x[:winner] }
    {
      title: 'Ace of Fire',
      description: 'Most times someone scored above 15 points or receieved "Best Match".',
      winners: winners,
      runnersup: runnersup,
      has_pairs: false,
      is_hot: true,
      is_warm: false,
      is_cold: false
    }
  end

  def most_warm
    winners, runnersup = most_matches(@is_warm).partition { |x| x[:winner] }
    {
      title: 'Ace of Frogs',
      description: 'Most times someone scored above 5 but less than 15 points.',
      winners: winners,
      runnersup: runnersup,
      has_pairs: false,
      is_hot: false,
      is_warm: true,
      is_cold: false
    }
  end

  def most_cold
    winners, runnersup = most_matches(@is_cold).partition { |x| x[:winner] }
    {
      title: 'Ace of Frost',
      description: 'Most times someone scored below 5 points.',
      winners: winners,
      runnersup: runnersup,
      has_pairs: false,
      is_hot: false,
      is_warm: false,
      is_cold: true
    }
  end

  def most_firsts
    winners, runnersup = most_matches(@is_best).partition { |x| x[:winner] }
    {
        title: 'Queen of Hearts',
        description: 'Most times someone scored "Best Match".',
        winners: winners,
        runnersup: runnersup,
        has_pairs: false,
        is_hot: false,
        is_warm: false,
        is_cold: false
      }
  end

  def most_lasts
    winners, runnersup = most_matches(@is_worst).partition { |x| x[:winner] }
    {
      title: 'Joker',
      description: 'Most times someone scored "Worst Match".',
      winners: winners,
      runnersup: runnersup,
      has_pairs: false,
      is_hot: false,
      is_warm: false,
      is_cold: false
    }
  end

  def highest_points_scored 
    top_two_scores = get_top_two_cards(@is_best)
    winners, runnersup = dedup(top_two_scores).partition { |x| x[:winner] }
    {
      title: 'Royal Flush',
      description: 'Highest points accumulated between two individuals.',
      winners: winners,
      runnersup: runnersup,
      has_pairs: true,
      is_hot: false,
      is_warm: false,
      is_cold: false
    }
  end

  def lowest_points_scored 
    top_two_scores = get_top_two_cards(@is_worst)
    winners, runnersup = dedup(top_two_scores).partition { |x| x[:winner] }
    {
      title: 'Bookends',
      description: 'Lowest points accumulated between two individuals.',
      winners: winners,
      runnersup: runnersup,
      has_pairs: true,
      is_hot: false,
      is_warm: false,
      is_cold: false
    }
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

  def sort_rankings
    @all_ranked_matches.each do |rankings|
      name = rankings[:name]
      rankings[:ranked_matches].each do |ranked_match| 
        @is_best << get_score_card(name, ranked_match) if ranked_match[:is_best]    
        @is_worst << get_score_card(name, ranked_match) if ranked_match[:is_worst]
        @is_hot << get_score_card(name, ranked_match) if ranked_match[:is_hot]
        @is_warm << get_score_card(name, ranked_match) if ranked_match[:is_warm]
        @is_cold << get_score_card(name, ranked_match) if ranked_match[:is_cold]
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
      rank[:winner] = true if rank[:score] == first
      top_two << rank if rank[:score] == first || rank[:score] == second
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
      score: match[:score],
      winner: false
    }
  end

end

