
require "nokogiri"

require_relative "kanji"

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
