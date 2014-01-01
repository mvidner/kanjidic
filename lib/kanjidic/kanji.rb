require "pp"

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

  # node is a Nokogiri::XML::Node
  def old_initialize(node)
    @node = node

    @literal = avalue ["literal"]

    @ucs    = avalue(%w(codepoint cp_value), "cp_type", "ucs").to_i(16)
    @jis208 = avalue %w(codepoint cp_value), "cp_type", "jis208"
    @jis212 = avalue %w(codepoint cp_value), "cp_type", "jis212"
    @jis213 = avalue %w(codepoint cp_value), "cp_type", "jis213"

    @radical        = iavalue %w(radical rad_value), "rad_type", "classical"
    @radical_nelson = iavalue %w(radical rad_value), "rad_type", "nelson_c"

    @grade = iavalue %w(misc grade)
    # TODO stroke_counts: find by any
    @stroke_counts = iavalues %w(misc stroke_count)
    # TODO variants, how to represent
    @freq = iavalue %w(misc freq)
    # TODO multiple
    @rad_names = avalues %w(misc rad_name)
    @jlpt = iavalue %w(misc jlpt)

    @heisig = iavalue %w(dic_number dic_ref), "dr_type", "heisig"

    @skip = avalue %w(query_code q_code), "qc_type", "skip"
    # also misclassifications

    # TODO many rmgroups
    @pinyins  = avalues %w(reading_meaning rmgroup reading), "r_type", "pinyin"
    @korean_rs= avalues %w(reading_meaning rmgroup reading), "r_type", "korean_r" 
    @korean_hs= avalues %w(reading_meaning rmgroup reading), "r_type", "korean_h"
    @ons      = avalues %w(reading_meaning rmgroup reading), "r_type", "ja_on"
    @kuns     = avalues %w(reading_meaning rmgroup reading), "r_type", "ja_kun"
#    @meanings = values "reading_meaning/rmgroup/meaning[not(@m_lang)]"

    # no longer needed
    @node = nil
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

  private

  def values(xpath)
    nodeset = @node.xpath(xpath)
    nodeset.map &:content
  end

  def ivalues(xpath)
    values(xpath).map(&:to_i)
  end

  def value(xpath)
    nodeset = @node.xpath(xpath)
    return nil if nodeset.empty? 
    nodeset.first.content
  end

  def avalues(elements, attr = nil, value = nil, node = nil)
    node ||= @node
#puts "NAME #{node.name}"
    tag = elements.shift
    if tag.nil?
#puts "TEXT #{node.text}"
      return node.text
    end
    matching = node.all_named(tag)
    if elements.empty?
      if not attr.nil?
        matching = matching.find_all do |n|
          n[attr] == value
        end
      end
    end
    matching.map do |n|
      avalues(elements, attr, value, n)
    end.flatten
  end

  def avalue(elements, attr = nil, value = nil, node = nil)
    avalues(elements, attr, value, node).first
  end

  def ivalue(xpath)
    iavalue(xpath)
  end

  def iavalue(*args)
    v = avalue(*args)
    return nil if v.nil?
    v.to_i
  end

  def iavalues(*args)
    avalues(*args).map &:to_i
  end
end
