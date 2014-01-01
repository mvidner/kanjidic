
require "nokogiri"
require "pp"

require_relative "kanji"

class Nokogiri::XML::Node
  def all_named(name)
    element_children.find_all do |child|
      child.name == name
    end
  end
end

class Kanjidic < Nokogiri::XML::SAX::Document
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

  def all
    # @doc.xpath("/kanjidic2/character").map {|node| Kanji.new(node)}
#    @doc.root.all_named("character").map {|node| Kanji.new(node)}
    @kanji
  end

  def start_element(name, attributes = [])
    if name == "character"
      @current_kanji = Kanji.new
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
#      pp @current_kanji
      @kanji << @current_kanji
      @current_kanji = nil
    end
  end

  def find(literal)
    @doc.xpath("/kanjidic2/character[literal = '#{literal}']").map {|node| Kanji.new(node)}.first
  end
end
