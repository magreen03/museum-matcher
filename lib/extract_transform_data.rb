class ExtractTransformData
  def initialize(data, range)
    @data = data
    @names = data[0][1..12]
    @range = range
  end

  def get_museums
    pref_with_museum
  end

  def transform_museums
    @names.map do |museum_name|
      Museum.new(museum_name)
    end
  end

  def transform_preferences
    museum_pref_hash = Hash.new
    @data[1..@range].each do |val|
      current_museum = val[0]
      current_museum_pref_hash = Hash.new
      val[1..@range].each_with_index do |val, index|
        current_museum_pref_hash[@names[index]] = val.to_i
      end

      museum_pref_hash[current_museum] = Hash[current_museum_pref_hash.sort_by{|k, v| v}]
    end
    museum_pref_hash
  end

  def pref_with_museum
    museums = transform_museums
    transform_preferences.each do |pref_hash|
      museums_prefs = pref_hash[1]
      temp_hash = Hash.new
      current_museum = museums.find { |museum| museum.name == pref_hash[0] }
      museums_prefs.each do |pref|
        next if current_museum.name == pref[0]
        m = museums.find { |museum| museum.name == pref[0] }
        temp_hash[m] = pref[1]
      end
      current_museum.preferences = temp_hash
    end
    museums
  end

end
