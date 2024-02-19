require 'csv'

class MissingPrompt < StandardError
end

class MatchMaker

  PC_NAMES = ["Korjar", "Obie", "Swam", "Asper"]
  PEOPLE_NAMES = ["Hannah", "Maddo", "Asif", "thewanderer"]
  EXTENDED_SECTIONS = ["romantic", "friendship", "family"]
  NAME_PROMPT = "How would you like to be called?"
  
  def verify_questions
    prompts = @questions.map { |question| question[:prompt]}
    headers = csv.headers
    prompts.each do |prompt| 
      raise MissingPrompt.new "#{prompt}" if !headers.include?(prompt)
    end
  end

  def all_names
    names = []
    csv.each_with_index do |row, index|
      names << row[NAME_PROMPT]
    end
    names
  end

  def csv
    CSV.read("#{Dir.pwd}/app/data/results.csv", headers: true)
  end

  def initialize(name, include_pcs = false, include_people = false, include_extended_sections = false)
    @name = name
    @include_pcs = include_pcs
    @include_people = include_people
    @include_extended_sections = include_extended_sections
    @questions = QuestionInfo.new.questions
    verify_questions
    return self
  end

  def build_quiz
    csv.select { |row| return row if row[NAME_PROMPT] == @name }
  end

  def name
    @name
  end

  def quiz
    @quiz ||= build_quiz
  end

  def build_dealbreakers
    questions = @questions.select { |question| question[:type] == 'dealbreaker'}
    return questions.map do |question|
      prompt = question[:prompt]
      quiz[question[:dealbreaker_decision]] == 'Dealbreaker' ? prompt : nil
    end.compact
  end

  def dealbreakers
    @dealbreakers ||= build_dealbreakers
  end

  def section_included(section)
    return true if @include_extended_sections
    !EXTENDED_SECTIONS.include?(section)
  end

  def match_included(name)
    return false if name == @name
    exclude = []
    exclude.concat(PC_NAMES) if !@include_pcs
    exclude.concat(PEOPLE_NAMES) if !@include_people
    !exclude.include?(name)
  end

  def build_possible_matches
    possible_matches = []
    csv.each_with_index do |row, index|
      possible_matches << row if match_included(row[NAME_PROMPT])
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
      @questions.each_with_index do |question, index|
        question_score = 0
        prompt = question[:prompt]
        next if !section_included(question[:section])
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