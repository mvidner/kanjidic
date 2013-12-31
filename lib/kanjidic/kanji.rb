class Kanji
  # node is a Nokogiri::XML::Node
  def initialize(node)
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
