require "pp"

class RawKanji
  # Data that is found in (XPath) /character//element
  # @param element [Symbol]
  def self.data(element)
  end

  # Data that is found in (XPath) /character//element/@attribute
  # @param element [Symbol]
  # @param attribute [Symbol] like :@foo
  def self.attribute_data(element, attribute)
  end

  def self.categorized_data(name, category_attribute)
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

  attribute_data :dic_ref, :@m_vol
  attribute_data :dic_ref, :@m_page

  categorized_data :q_code, :@qc_type
  # FIXME
  categorized_data [:q_code, "skip"], :@skip_misclass

  categorized_data :reading, :@r_type
  categorized_data :meaning, :@m_lang
end

class RawKanjiOld
  # @param where [String] xpath to initialize it from,
  #   assuming a "/character" prefix.
  def self.data(name, where = "//#{name}")
  end

  data :literal

  data :cp_value_jis208, "//cp_value[@cp_type='jis208']"
  data :cp_value_jis212, "//cp_value[@cp_type='jis212']"
  data :cp_value_jis213, "//cp_value[@cp_type='jis213']"
  data :cp_value_ucs,    "//cp_value[@cp_type='ucs']"

  data :rad_value_classical, "//rad_value[@rad_type='classical']"
  data :rad_value_nelson_c,  "//rad_value[@rad_type='nelson_c']"

  data :grade
  data :stroke_count

  data :variant_jis208,   "//variant[@var_type='jis208']"
  data :variant_jis212,   "//variant[@var_type='jis212']"
  data :variant_jis213,   "//variant[@var_type='jis213']"
  data :variant_deroo,    "//variant[@var_type='deroo']"
  data :variant_njecd,    "//variant[@var_type='njecd']"
  data :variant_s_h,      "//variant[@var_type='s_h']"
  data :variant_nelson_c, "//variant[@var_type='nelson_c']"
  data :variant_oneill,   "//variant[@var_type='oneill']"
  data :variant_ucs,      "//variant[@var_type='ucs']"

  data :freq
  data :rad_name
  data :jlpt

  data :dic_ref_nelson_c,          "//dic_ref[@dr_type='nelson_c']"
  data :dic_ref_nelson_n,          "//dic_ref[@dr_type='nelson_n']"
  data :dic_ref_halpern_njecd,     "//dic_ref[@dr_type='halpern_njecd']"
  data :dic_ref_halpern_kkld,      "//dic_ref[@dr_type='halpern_kkld']"
  data :dic_ref_heisig,            "//dic_ref[@dr_type='heisig']"
  data :dic_ref_gakken,            "//dic_ref[@dr_type='gakken']"
  data :dic_ref_oneill_names,      "//dic_ref[@dr_type='oneill_names']"
  data :dic_ref_oneill_kk,         "//dic_ref[@dr_type='oneill_kk']"
  data :dic_ref_moro,              "//dic_ref[@dr_type='moro']"
  data :dic_ref_henshall,          "//dic_ref[@dr_type='henshall']"
  data :dic_ref_sh_kk,             "//dic_ref[@dr_type='sh_kk']"
  data :dic_ref_sakade,            "//dic_ref[@dr_type='sakade']"
  data :dic_ref_jf_cards,          "//dic_ref[@dr_type='jf_cards']"
  data :dic_ref_henshall3,         "//dic_ref[@dr_type='henshall3']"
  data :dic_ref_tutt_cards,        "//dic_ref[@dr_type='tutt_cards']"
  data :dic_ref_crowley,           "//dic_ref[@dr_type='crowley']"
  data :dic_ref_kanji_in_context,  "//dic_ref[@dr_type='kanji_in_context']"
  data :dic_ref_busy_people,       "//dic_ref[@dr_type='busy_people']"
  data :dic_ref_kodansha_compact,  "//dic_ref[@dr_type='kodansha_compact']"
  data :dic_ref_maniette,          "//dic_ref[@dr_type='maniette']"

  data :dic_ref_m_vol,  "//dic_ref[@dr_type='moro']/@m_vol"
  data :dic_ref_m_page, "//dic_ref[@dr_type='moro']/@m_page"

  data :q_code_sh_desc,                    "//q_code[@qc_type='sh_desc']"
  data :q_code_four_corner,                "//q_code[@qc_type='four_corner']"
  data :q_code_deroo,                      "//q_code[@qc_type='deroo']"
  data :q_code_skip_without_skip_misclass,
                "//q_code[@qc_type='skip' and @skip_misclass='']"
  data :q_code_skip_misclass_posn,
                "//q_code[@qc_type='skip' and @skip_misclass='posn']"
  data :q_code_skip_misclass_stroke_count,
                "//q_code[@qc_type='skip' and @skip_misclass='stroke_count']"
  data :q_code_skip_misclass_stroke_and_posn,
                "//q_code[@qc_type='skip' and @skip_misclass='stroke_and_posn']"
  data :q_code_skip_misclass_stroke_diff,
                "//q_code[@qc_type='skip' and @skip_misclass='stroke_diff']"

  data :reading_pinyin,   "//reading[@r_type='pinyin']"
  data :reading_korean_r, "//reading[@r_type='korean_r']"
  data :reading_korean_h, "//reading[@r_type='korean_h']"
  data :reading_ja_on,    "//reading[@r_type='ja_on']"
  data :reading_ja_kun,   "//reading[@r_type='ja_kun']"

  data :meaning_without_m_lang, "//meaning[@m_lang='']"
  data :meaning_fr,             "//meaning[@m_lang='fr']"
  data :meaning_es,             "//meaning[@m_lang='es']"
  data :meaning_pt,             "//meaning[@m_lang='pt']"
end

class Attr
  attr_accessor :name
  attr_accessor :tags
  attr_accessor :attr
  attr_accessor :value
  attr_accessor :add

  def initialize(name, *args)
    self.name = name.to_s
    if args.last.is_a? Hash
      opt = args.pop
      self.attr  = opt.first[0]
      self.value = opt.first[1]
    end
    self.tags = args
    self.add = lambda {|old, value| value}
  end

  def reset(kanji)
#    puts "RESET #{kanji}"
    kanji.instance_variable_set("@#{name}", nil)
  end

  def text(kanji, value)
    old = kanji.instance_variable_get("@#{name}")
    value = add.call(old, value)
    kanji.instance_variable_set("@#{name}", value)
  end
end

class Kanji
  @@attrs = {}
  @@tags = {}
  @@buffer = nil
  @@text_target = nil

  def self.attr(*args)
    a = Attr.new *args
    @@attrs[a.name] = a
    @@tags[a.tags.last] = a
    a
  end

  def self.text(*args)
    attr(*args)
  end

  def self.texts(*args)
    attr(*args).add = lambda { |old, value| (old || Array.new) << value }
  end

  def self.int(*args)
    attr(*args).add = lambda { |old, value| value.to_i }
  end

  text :literal, "literal"
  # FIXME to_i(16)
  text :ucs, "codepoint", "cp_value", "cp_type" => "ucs"
  
  int :grade, "misc", "grade"
  texts :ons, "reading_meaning", "rmgroup", "reading", "r_type" => "ja_on"

  def initialize
    @@attrs.values.each do |a|
      a.reset(self)
    end
    @ons = []
  end

  def start_element(name, attributes = [])
    handler = @@tags[name]
    return unless handler
    if handler.attr
      return unless attributes.any? do |a, v|
        a == handler.attr && v == handler.value
      end
    end
    @@buffer = ""
    @@text_target = handler
  end

  def characters(string)
    if @@buffer
#      @@buffer << string
      @@buffer = string
    end
  end

  def end_element(name)
    @@text_target.text(self, @@buffer) if @@text_target
    @@buffer = nil
    @@text_target = nil
#    pp self
  end

  attr_reader :literal
  # integer, unicode code point
  attr_reader :ucs
  attr_reader :grade
  attr_reader :stroke_count
  attr_reader :heisig
  attr_reader :pinyins, :ons, :kuns
  attr_reader :meanings

  def summary
    "<%s U+%04X G%d Hg%d %s>" %
      [literal, ucs, grade||0, heisig||0, meanings.join("/")]
  end

end
