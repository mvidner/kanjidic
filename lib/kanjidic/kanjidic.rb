require_relative "parser"

class Kanjidic
  DEFAULT_FILENAME = "/usr/share/kanjidic2/kanjidic2.xml"

  def initialize(filename = DEFAULT_FILENAME)
    parser = Kanjidic::Parser.new(filename)
    @raw_kanji = parser.all
  end

  def all
    # TODO lazy generator?
    @raw_kanji.map {|r| Kanji.new(r) }
  end

end
