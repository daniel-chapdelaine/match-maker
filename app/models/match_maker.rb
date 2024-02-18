require 'csv'

class NoPromptFound < StandardError
end

class MatchMaker

  PC_NAMES = ["Korjar", "Obie", "Swam of Wadyr, Trained Carpenter", "Asper (aka: Sunshine, Ass-per, BBG, “the scary one”, yours 😏)"]
  NAME_PROMPT = "How would you like to be called?"
  QUESTIONS = [
    {
      prompt: "You sit down for an enticing card game of Three Dragon Ante. Which deck do you choose?",
      type: "exact"
    },
    {
      prompt: "If you were to have your own house in Gourd Poggers, what neighborhood would you build in?",
      type: "exact"
    },
    {
      prompt: "Select 3 for your mood board:",
      type: "contains"
    },
    {
      prompt: "If you were traveling through Sannas and stopped for their famous fire-red flatbread, what toppings would you choose? (choose none, all or any in between)",
      type: "flatbread"
    },
    {
      prompt: "Which hatronus is most likely to catch your eye?",
      type: "exact"
    },
    {
      prompt: "You are suddenly asked to travel with Marshall Margud by Marshall Margud. His eyes quiver as he eagerly awaits your answer. You can't bring yourself to break his heart so you respond affirmatively. How long would you last?",
      type: "exact"
    },
    {
      prompt: "Scribe Poggers is too strict...",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Peryton]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Beholder]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Cranium Rat]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Owlbear]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Displacer Beast]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Gelatinous Cube]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Tarrasque]",
      type: "exact"
    },
    {
      prompt: "Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Intellect Devourer]",
      type: "exact"
    },
    {
      prompt: "Smoking or non-smoking?",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Smoking-Nonsmoking]"
    },
    {
      prompt: "Shoes in the house: on or off?",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [ShoesOn-ShoesOff]"
    },
    {
      prompt: "Eat with hands or eat with sporks?",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Hands-Sporks]"
    },
    {
      prompt: "I wanna go...",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Farwide-Deepnarrow]]"
    },
    {
      prompt: "When I make my bed I...",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Bed Made-Bed Unmade]"
    },
    {
      prompt: "When you want to visit someone's home but they don't seem to be around to let you in, it is most important to...",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Doors-Windows]"
    },
    {
      prompt: "PoV:",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [PoV]"
    },
    {
      prompt: "Bite or Bit?",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Bite-Bit]"
    },
    {
      prompt: "Day or Night?",
      type: "dealbreaker",
      dealbreaker_decision: "Dealbreaker? [Day-Night]"
    },
  ]

  def csv
    CSV.read("#{Dir.pwd}/app/data/results.csv", headers: true)
  end

  def initialize(name, include_players = false)
    @name = name
    @include_players = include_players
    return self
  end

  def build_quiz
    csv.select { |row| return row if row[NAME_PROMPT] == @name }
  end

  def quiz
    @quiz ||= build_quiz
  end

  def build_dealbreakers
    questions = QUESTIONS.select { |question| question[:type] == 'dealbreaker'}
    return questions.map do |question|
      prompt = question[:prompt]
      quiz[question[:dealbreaker_decision]] == 'Dealbreaker' ? prompt : nil
    end.compact
  end

  def dealbreakers
    @dealbreakers ||= build_dealbreakers
  end

  def inclusions(name)
    return false if name == @name
    return true if @include_players
    !PC_NAMES.include?(name)
  end

  def build_possible_matches
    possible_matches = []
    csv.each_with_index do |row, index|
      possible_matches << row if inclusions(row[NAME_PROMPT])
    end
    possible_matches
  end

  def possible_matches
    @possible_matches ||= build_possible_matches
  end

  def score_dealbreaker(prompt, match)
    if (quiz[prompt] == match.quiz[prompt]) 
      if (dealbreakers.include?(prompt) && match.dealbreakers.include?(prompt)) 
        return 3
      elsif (dealbreakers.include?(prompt) || match.dealbreakers.include?(prompt))
        return 2
      else
        return 1
      end
    else
      if (dealbreakers.include?(prompt) && match.dealbreakers.include?(prompt))
        return -3
      elsif (dealbreakers.include?(prompt) || match.dealbreakers.include?(prompt))
        return -2
      else
        return -1
      end
    end
  end

  def score_flatbread(a, b)
    return 0 if !a
    return 0 if !b
    score = 0
    list_one = a.split(',').collect(&:strip)
    list_two = b.split(',').collect(&:strip)
    list_one.each do |answer|
      break if score == 3 
      score += 1 if list_two.include?(answer) 

    end
    score += 1 if (list_one.count <= 5 && list_two.count <= 5)
    score += 1 if (list_one.count >= 10 && list_two.count >= 10)
    return score
  end

  def score_exact(a, b)
    return 0 if !a
    return 0 if !b
    return 1 if a == b 
    0
  end

  def score_contains(a, b)
    return 0 if !a
    return 0 if !b
    score = 0
    list_one = a.split(',').collect(&:strip)
    list_two = b.split(',').collect(&:strip)
    list_one.each do |answer|
      score += 1 if list_two.include?(answer) 
    end
    return score
  end

  def ranked_scores(limit = nil)
    ranked = scores.sort! { |a, b|  b[:score] <=> a[:score] }
    return ranked.slice(0, limit) if limit 
    ranked
  end

  def scores
    @scores || build_scores
  end

  def build_scores
    return possible_matches.map do |possible_match_quiz|
      match_person = MatchMaker.new(possible_match_quiz[NAME_PROMPT])
      score = 0
      puts "-------------------------   #{possible_match_quiz[NAME_PROMPT]}   --------------------------------------"
      QUESTIONS.each_with_index do |question, index|
        question_score = 0
        prompt = question[:prompt]
        raise NoPromptFound.new "#{prompt}" if !quiz[prompt] 
        raise NoPromptFound.new "#{prompt}" if !possible_match_quiz[prompt] 
        question_score += score_dealbreaker(prompt, match_person) if question[:type] == "dealbreaker"
        question_score += score_exact(quiz[prompt], possible_match_quiz[prompt]) if question[:type] == "exact"
        question_score += score_contains(quiz[prompt], possible_match_quiz[prompt]) if question[:type] == "contains"
        question_score += score_flatbread(quiz[prompt], possible_match_quiz[prompt]) if question[:type] == "flatbread"
        puts "#{index + 1}. #{prompt} [ #{question_score} ]"
        score += question_score
      end
      puts "-------------------------    FINAL: #{score}          --------------------------------------"
      puts "  "
      puts "  "
      {match: possible_match_quiz[NAME_PROMPT], score: score}
    end
  end

end