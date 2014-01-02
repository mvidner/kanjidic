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
