class Museum
  attr_accessor :partner, :preferences
  attr_reader   :name, :proposals

  def initialize(name)
    @name           = name
    @partner        = nil
    @preferences    = {}
    @proposals      = []
  end

  def open?
    @partner == nil
  end

  def open
    @partner = nil
  end

  def ranking
    if @partner
      @preferences[@partner]
    else
      0
    end
  end

  def print_prefs
    @preferences.each { |pref| print "#{pref}, "}
    puts ""
  end

  def partner_with(museum)
    puts "#{self} -> #{museum}" if $debug
    @partner = museum
    museum.partner = self
  end

  def better_match?(museum)
    return true if @partner == nil
    @preferences[museum] < @preferences[@partner] if @preferences.size > 0
  end

  def release_partner
    if !open?
      @partner.open if !(@partner.open?)
      self.open
    end
  end

  def respond_to_request(museum)
    self.open? || self.better_match?(museum) ? true : false
  end

  def to_s
    @name
  end

  def inspect
    "#<#{self}>"
  end
end
