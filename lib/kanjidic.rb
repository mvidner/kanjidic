# coding: utf-8
# cpoyright

require "nokogiri"
require "pp"

class Kanji
  def initialize(node)
#    pp node
    @node = node

    @literal = get("literal")

    @ucs = get("codepoint/cp_value[@cp_type = 'ucs']").to_i(16)
    @jis208 = get("codepoint/cp_value[@cp_type = 'jis208']")

    @radical = get("radical/rad_value[@rad_type ='classical']").to_i
    @radical_nelson = get("radical/rad_value[@rad_type ='nelson_c']").to_i

    @grade = get("misc/grade").to_i
    # TODO stroke_counts: find by any
    @stroke_count = get("misc/stroke_count").to_i
    # TODO variants, how to represent
    @freq = get("misc/freq").to_i
    # TODO multiple
    @rad_name = get("misc/rad_name")
    @jlpt = get("misc/jlpt").to_i

    @heisig = get("dic_number/dic_ref[@dr_type = 'heisig']").to_i

    @skip = get("query_code/q_code[@qc_type = 'skip']")
    # also misclassifications

    # TODO many
    @pinyin = get("reading_meaning/rmgroup/reading[@r_type = 'pinyin']")
    @on = get("reading_meaning/rmgroup/reading[@r_type = 'ja_on']")
    @kun = get("reading_meaning/rmgroup/reading[@r_type = 'ja_kun']")
    @meaning = get("reading_meaning/rmgroup/meaning")

    # no longer needed
    @node = nil
  end

  attr_reader :literal
  # integer, unicode code point
  attr_reader :ucs
  attr_reader :stroke_count

  private

  def get(xpath)
    @node.xpath(xpath).first.content rescue nil
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

# puts "number of kanji: #{d.all.size}"

onna = d.find "女"

# puts "onna: %s U+%04X, %d strokes" % [onna.literal, onna.ucs, onna.stroke_count]
pp onna
