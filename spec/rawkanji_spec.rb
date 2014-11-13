# encoding: utf-8

# require_relative "spec_helper"
require "kanjidic/parser"

describe Kanjidic::Parser do
  it "works" do
    p = Kanjidic::Parser.new(File.expand_path("../data/sample.xml", __FILE__))
    expect(p.all).to have_exactly(3).items

    k = p.all.first
    expect(k.literal).to                 eq ["亜"]
    expect(k.cp_value["ucs"]).to         eq ["4e9c"]
    expect(k.cp_value["jis208"]).to      eq ["16-01"]
    expect(k.rad_value["classical"]).to  eq ["7"]
    expect(k.rad_value["nelson_c"]).to   eq ["1"]
    expect(k.grade).to                   eq ["8"]
    # ...
    expect(k.meaning[""]).to      eq ["Asia", "rank next", "come after", "-ous"]
    expect(k.meaning["fr"]).to           eq ["Asie", "suivant", "sub-", "sous-"]
    # how to express missing fields? probably []

    # test also 2nd/nonfirst and 3rd/last characters
  end
end
