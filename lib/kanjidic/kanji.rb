class RawKanji
  # [Array<Symbol>]
  @@data = []
  # [Hash<Symbol, Symbol>] name -> category_attribute
  @@categorized_data = {}

  # Data that is found in (XPath) /character//name
  # and provided as .name
  # @param element [Symbol]
  def self.data(name)
    attr_reader name
    @@data << name.to_s
  end

  # Data that is found in (XPath) /character//element/@attribute
  # @param element [Symbol]
  # @param attribute [Symbol] like :@foo
#  def self.attribute_data(element, attribute)
#  end

  # Data that is found in (XPath) /character//name[@category_attribute=cat]/
  # and provided as .name[cat]
  # @param name[Symbol]
  def self.categorized_data(name, category_attribute)
    attr_reader name
    @@categorized_data[name.to_s] = category_attribute.to_s.sub(/^@/, "")
  end

  def initialize
    @@data.each do |d|
      instance_variable_set("@#{d}", [])
    end
    @@categorized_data.each do |d, attr|
      instance_variable_set("@#{d}", {})
    end
  end

  data :literal
  categorized_data :cp_value, :@cp_type
  categorized_data :rad_value, :@rad_type
  data :grade
  data :stroke_count
  categorized_data :variant, :@var_type
  data :freq
  data :rad_name
  data :jlpt

  categorized_data :dic_ref, :@dr_type

#  attribute_data :dic_ref, :@m_vol
#  attribute_data :dic_ref, :@m_page

  categorized_data :q_code, :@qc_type
  # FIXME
#  categorized_data [:q_code, "skip"], :@skip_misclass

  categorized_data :reading, :@r_type
  categorized_data :meaning, :@m_lang

  def start_element(name, attributes)
    @string = ""
    if @@data.include? name
      @target = instance_variable_get("@#{name}")
    elsif @@categorized_data.has_key? name
      attributes = Hash[attributes]
      category_attribute = @@categorized_data[name]
      category = attributes.fetch(category_attribute, "")
      hash = instance_variable_get("@#{name}")
      @target = (hash[category] ||= [])
    else
      @target = nil
    end
  end

  def characters(string)
    if @target
      @string << string
    end
  end

  def end_element(name)
    if @target
      @target << @string
    end
    @target = nil
    @string = ""
  end
end

class Kanji
  def initialize(raw_kanji)
    @raw = raw_kanji
  end

  def data(name, group = nil)
    if group
      @raw.send(group.to_s)[name.to_s] || []
    else
      @raw.send(name.to_s) || []
    end
  end
  private :data

  def self.text(name, group = nil)
    define_method(name) do
      data(name, group).first
    end
  end

  def self.int(name, group = nil)
    define_method(name) do
      data(name, group).first.to_i # nil -> 0
    end
  end

  text :literal
  def ucs
    @raw.cp_value["ucs"].first.to_i(16)
  end
  text :jis208, :cp_value
  def radical
    @raw.rad_value["classical"].first.to_i
  end
  def grade
    (@raw.grade.first || "99").to_i
  end
  int :stroke_count
  # :variant?
  int :freq
  int :jlpt

  [
    "nelson_c",
    "nelson_n",
    "halpern_njecd",
    "halpern_kkd",
    "halpern_kkld",
    "halpern_kkld_2ed",
    "heisig",
    "heisig6",
    "gakken",
    "oneill_names",
    "oneill_kk",
    "moro",
    "henshall",
    "sh_kk",
    "jf_cards",
    "tutt_cards",
    "kanji_in_context",
    "kodansha_compact",
    "maniette"
  ].each do |dict|
    int dict.to_sym, :dic_ref
  end

  text :skip,        :q_code
  text :sh_desc,     :q_code
  text :four_corner, :q_code
  text :deroo,       :q_code
  
  def ja_kun;   @raw.reading["ja_kun"] || [];  end
  def ja_on;    @raw.reading["ja_on"] || [];  end
end
