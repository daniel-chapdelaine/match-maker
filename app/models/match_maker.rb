require 'csv'

class NoQuestionFound < StandardError
end

class MatchMaker

  NAME_QUESTION = "How would you like to be called?"
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
      type: "contains"
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
    # How would you like to be called?,You sit down for an enticing card game of Three Dragon Ante. Which deck do you choose?,"If you were to have your own house in Gourd Poggers, what neighborhood would you build in?",Select 3 for your mood board:,"If you were traveling through Sannas and stopped for their famous fire-red flatbread, what toppings would you choose? (choose none, all or any in between) ",Which hatronus is most likely to catch your eye?  ,You are suddenly asked to travel with Marshall Margud by Marshall Margud. His eyes quiver as he eagerly awaits your answer. You can't bring yourself to break his heart so you respond affirmatively. How long would you last?  ,Scribe Poggers is too strict...,"Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Peryton]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Beholder]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Cranium Rat]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Owlbear]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Displacer Beast]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Gelatinous Cube]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Tarrasque]","Rate the following monsters from most to least likely to be found in Mayor Poggers' basement.(1 being most likely and 8 being least. One answer per column!)   [Intellect Devourer]",What kind of match are you hoping to make today?,Greatest relational fear?,"Above all, you want to build partnerships that:","😳, 🥱, 🫦 [Rus]","😳, 🥱, 🫦 [Lufkin]","😳, 🥱, 🫦 [Uno]","😳, 🥱, 🫦 [Mina]","😳, 🥱, 🫦 [Duineglic]","😳, 🥱, 🫦 [Noona]","😳, 🥱, 🫦 [Adeiventi]","😳, 🥱, 🫦 [Alvir]","😳, 🥱, 🫦 [Yanta]","😳, 🥱, 🫦 [Bachelor Poggers]",What best describe your current relationship aspirations?  ,Best location for a romantic evening?,"Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [Clean, quiet, curteous]","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [Rowdy and ready to rumble]","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [On the verge of something big]","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [Trying to get back out there]","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [Rovin', ramblin', wanderin']","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [Starting a new chapter]","Mix and Match to make a personal ad - ""I am [row], looking for [column]"" [What I am]",How do you fit into the social landscape? [Smoker's Circle],How do you fit into the social landscape? [The Band],How do you fit into the social landscape? [The Dads],How do you fit into the social landscape? [Athletics Club],How do you fit into the social landscape? [Bar Regulars],How do you fit into the social landscape? [Field Hands],How do you fit into the social landscape? [Store Generals],How do you fit into the social landscape? [Thicketers],How do you fit into the social landscape? [Mine Enthusiasts],Favorite place to hang out on a day off?,My closest friend...,I tend to get along best with...,"If you had to join a Gourd Poggers famiy unit, you'd be most happy as an honorary....","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Sante]","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Poggers]","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Samira]","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Bez]","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Doc]","When seeking guidance from an elder, I consider [insert name from row]... (check all that apply) [Hanare]",What's your ideal family size?,Do you need your own bedroom?,"If Doc was hypothetically under the consultation table ready to spring out and welcome you as his foster child as soon as you sign on this line, would you like him to throw the confetti or not?",Smoking or non-smoking?,Dealbreaker? [Smoking-Nonsmoking],Shoes in the house: on or off?,Dealbreaker? [ShoesOn-ShoesOff],Eat with hands or eat with sporks?,Dealbreaker? [Hands-Sporks],I wanna go...,Dealbreaker? [Farwide-Deepnarrow],When I make my bed I...,Dealbreaker? [Bed Made-Bed Unmade],"When you want to visit someone's home but they don't seem to be around to let you in, it is most important to...",Dealbreaker? [Doors-Windows],PoV:,Dealbreaker? [PoV],Bite or Bit?,Dealbreaker? [Bite-Bit],Day or Night?,Dealbreaker? [Day-Night]

  ]

  def csv
    CSV.read("#{Dir.pwd}/app/data/results.csv", headers: true)
  end

  def initialize(name)
    @name=name
    csv.each_with_index do |row, index|
      @person = row if row[NAME_QUESTION] == name
    end
    return self
  end

  def name
    @name
  end

  def person
    @person
  end

  def build_possible_matches
    possible_matches = []
    csv.each_with_index do |row, index|
      possible_matches << row if index >= 4
    end
    possible_matches
  end

  def possible_matches
    @possible_matches ||= build_possible_matches
  end

  def exact(a, b)
    return 0 if !a
    return 0 if !b
    return 1 if a == b 
    0
  end

  def contains(a, b)
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
    return possible_matches.map do |match|
      score = 0
      puts "-------------------------   #{match[NAME_QUESTION]}   --------------------------------------"
      QUESTIONS.each_with_index do |question, index|
        question_score = 0
        prompt = question[:prompt]
        raise NoQuestionFound.new "#{prompt}" if !@person[prompt] 
        raise NoQuestionFound.new "#{prompt}" if !match[prompt] 
        question_score += exact(@person[prompt], match[prompt]) if question[:type] == "exact"
        question_score += contains(@person[prompt], match[prompt]) if question[:type] == "contains"
        puts "#{index + 1}. #{prompt} [ #{question_score} ]"
        score += question_score
      end
      puts "-------------------------    FINAL: #{score}          --------------------------------------"
      puts "  "
      puts "  "
      {match: match[NAME_QUESTION], score: score}
    end
  end

end