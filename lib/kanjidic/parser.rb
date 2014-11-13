require "nokogiri"

require_relative "kanji"
class Kanjidic
end

class Kanjidic::Parser < Nokogiri::XML::SAX::Document
  DEFAULT_FILENAME = "/usr/share/kanjidic2/kanjidic2.xml"

  def initialize(filename = DEFAULT_FILENAME)
    @kanji = []
    @current_kanji = nil

    parser = Nokogiri::XML::SAX::Parser.new(self) do |config|
      config.strict
      config.nonet
    end

    parser.parse(File.open(filename))
  end

  # @return [Array<RawKanji>]
  def all
    @kanji
  end

  private

  def start_element(name, attributes = [])
    if name == "character"
      @current_kanji = RawKanji.new
    end
    if @current_kanji
      @current_kanji.start_element(name, attributes)
    end
  end

  def characters(string)
    if @current_kanji
      @current_kanji.characters(string)
    end
  end

  def end_element(name)
    if @current_kanji
      @current_kanji.end_element(name)
    end
    if name == "character"
      @kanji << @current_kanji
      @current_kanji = nil
    end
  end

end
