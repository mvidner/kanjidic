# coding: utf-8
# cpoyright

require "nokogiri"
require "pp"

class Kanji
  def initialize(node)
#    pp node
    @node = node

    @literal = value "literal" 

    @ucs = value("codepoint/cp_value[@cp_type = 'ucs']").to_i(16)
    @jis208 = value "codepoint/cp_value[@cp_type = 'jis208']"
    @jis212 = value "codepoint/cp_value[@cp_type = 'jis212']"
    @jis213 = value "codepoint/cp_value[@cp_type = 'jis213']"

    @radical = ivalue "radical/rad_value[@rad_type = 'classical']"
    @radical_nelson = ivalue "radical/rad_value[@rad_type = 'nelson_c']"

    @grade = ivalue "misc/grade"
    # TODO stroke_counts: find by any
    @stroke_counts = ivalues "misc/stroke_count"
    # TODO variants, how to represent
    @freq = ivalue "misc/freq"
    # TODO multiple
    @rad_names = values "misc/rad_name"
    @jlpt = ivalue "misc/jlpt"

    @heisig = ivalue "dic_number/dic_ref[@dr_type = 'heisig']"

    @skip = value "query_code/q_code[@qc_type = 'skip']"
    # also misclassifications

    # TODO many rmgroups
    @pinyins  = values "reading_meaning/rmgroup/reading[@r_type = 'pinyin']"
    @korean_rs= values "reading_meaning/rmgroup/reading[@r_type = 'korean_r']" 
    @korean_hs= values "reading_meaning/rmgroup/reading[@r_type = 'korean_h']" 
    @ons      = values "reading_meaning/rmgroup/reading[@r_type = 'ja_on']" 
    @kuns     = values "reading_meaning/rmgroup/reading[@r_type = 'ja_kun']"
    @meanings = values "reading_meaning/rmgroup/meaning[not(@m_lang)]"

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
  end

  def value(xpath)
    nodeset = @node.xpath(xpath)
    return nil if nodeset.empty? 
    nodeset.first.content
  end

  def ivalue(xpath)
    v = value(xpath)
    return nil if v.nil?
    v.to_i
  end
end

class Kanjidic
  DEFAULT_FILENAME = "/usr/share/kanjidic2/kanjidic2.xml"

  def initialize(filename = DEFAULT_FILENAME)
    f = File.open(filename)
    @doc = Nokogiri::XML(f) do |config|
      config.strict.nonet
    end
    f.close
  end

  def all
    @doc.xpath("/kanjidic2/character").map {|node| Kanji.new(node)}
  end

  def find(literal)
    @doc.xpath("/kanjidic2/character[literal = '#{literal}']").map {|node| Kanji.new(node)}.first
  end
end

# test
d = Kanjidic.new
#d = Kanjidic.new "kanjidic2-sample.xml"
a = d.all

# h = a.find_all {|k| k.heisig }
# h.sort_by {|k| [k.grade || 99, k.heisig]}.each {|k| puts k}

#r = a.find_all {|k| k.ons.include? "コク"}
#r.each {|k| puts k.summary; pp k}

kyouiku = a.find_all {|k| (k.grade||99) <= 6 }
by_on = {}
kyouiku.each do |k|
  k.ons.each do |on|
    by_on[on] ||= []
    by_on[on] << k
  end
end

by_on.keys.sort.each do |on|
  puts "<h2>#{on}</h2>"
  by_on[on].sort_by{|k| k.grade}.each do |k|
    print "#{k.literal}(#{k.grade||''}) "
  end
  puts
end
