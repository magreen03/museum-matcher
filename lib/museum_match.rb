class MuseumMatch
  attr_reader :museums

  def initialize(museums)
    @museums = museums.shuffle!
  end

  def show_rankings(museum_name)
    m_obj = @museums.find {|m| m.name == museum_name}
    puts m_obj.preferences
  end

  def survey_responses
    count = 0
    @museums.map {|m| count += 1 if m.preferences.size > 0 }
    count
  end

  def most_popular
    popular_list = Hash.new(0)
    @museums.each do |museum|
      next if !museum.preferences
      museum.preferences.each do |name, val|
        popular_list[name] += val.to_i
      end
    end

    popular_list = popular_list.sort_by{|k, v| v}
    popular_list.each_with_index do |(n, v), index|
      puts "#{index+1}: #{n}(#{v})"
    end
  end

  def print_matches
    buffer = 45
    puts "#{" " * (buffer - 13)} *** Matches ***"
    @museums.each do |museum|
      space = buffer - (2 + museum.ranking.to_s.size) - museum.name.size
      if museum.partner
        print "#{museum.name}(#{museum.ranking})#{" " * space}|"
        puts "  #{museum.partner.name}(#{museum.partner.ranking})"
      else
        puts "#{museum.name}(-)#{" " * space}|"
      end
    end
  end

  def print_order
    puts "Current Order:"
    @museums.each_with_index {|m, i| puts "#{i+1}: #{m}"}
  end

  def quick_match
    puts "***** Begin Matching *****" if $debug
    for i in 0...@museums.size
      current_museum = @museums[i]
      if current_museum.preferences.size > 0 && current_museum.open?
        om = current_museum.preferences.find do |other_museum, rank|
          other_museum.open? && !current_museum.proposals.include?(other_museum) && @museums.include?(other_museum)
        end

        if om
          current_museum.partner_with om.first
        else
          next
        end
      else
        if $debug
          print "- #{@museums[i]} skipped: "
          puts current_museum.preferences.size == 0 ? "no preferences" : "has partner"
        end
      end
    end
      puts "***** End Matching *****"  if $debug
  end

  def unhappy?
    count = 0
    @museums.map {|m| count += 1 if has_better_match?(m) }
    count
  end

  def has_better_match?(museum)
    if museum.preferences.size > 0  && museum.partner
      current_partner_ranking = museum.ranking
      for i in 1...current_partner_ranking
        prospective_partner = museum.preferences.key(i)
        if !museum.proposals.include?(prospective_partner) &&
             @museums.include?(prospective_partner)
          return true
        end
      end
      return false
    else
      false
    end
  end

  def find_better_matches
    puts "***** Start Better Match Check *****"  if $debug
    @museums.each do |m|
      if m.preferences.size > 0
        current_partner_ranking = m.ranking
        puts "--------   #{m.inspect}     ---------" if $debug
        puts "current partner, #{m.partner}, is ranked: #{current_partner_ranking}" if $debug
        if current_partner_ranking > 1
          for i in 1...current_partner_ranking
            prospective_partner = m.preferences.key(i)
            puts "Check to see if #{m} is a better match than #{prospective_partner}'s current partner" if $debug
            if !m.proposals.include?(prospective_partner) && prospective_partner.better_match?(m) && @museums.include?(prospective_partner)
              puts "#{m} is a better match for #{prospective_partner} than #{prospective_partner.partner}" if $debug
              m.release_partner
              prospective_partner.release_partner
              prospective_partner.partner_with m
              break
            else
              puts "#{prospective_partner}'s current partner has a higher rank... Adding to proposals list" if $debug
              m.proposals << prospective_partner
            end
          end
          puts "#{m} is going to stick with #{m.partner}" if $debug
        elsif current_partner_ranking == 0
          puts "doesn't have a partner" if $debug
        else
          puts "#{m.partner} is #1" if $debug
        end

      end
    end
    puts "***** End Better Match Check *****"  if $debug
  end

end
