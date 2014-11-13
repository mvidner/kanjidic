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
      hash_of_lists = Hash.new {|h, k| h[k] = [] }
      instance_variable_set("@#{d}", hash_of_lists)
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
    if @@data.include? name
      @target = instance_variable_get("@#{name}")
    elsif @@categorized_data.has_key? name
      attributes = Hash[attributes]
      category_attribute = @@categorized_data[name]
      category = attributes.fetch(category_attribute, "")
      hash = instance_variable_get("@#{name}")
      @target = hash[category]
    else
      @target = nil
    end
  end

  def characters(string)
    if @target
      @target << string
    end
    @target = nil
  end

  def end_element(name)
  end
end
