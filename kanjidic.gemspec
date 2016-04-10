# -*- mode: ruby; coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "kanjidic"
  s.version     = "0.0.2"
  s.summary     = "Kanjidic2 kanji dictionary"
  s.description = "Ruby API for http://www.csse.monash.edu.au/~jwb/kanjidic2/"

  s.author      = "Martin Vidner"
  s.email       = "martin@vidner.net"
  s.homepage    = "https://github.com/mvidner/kanjidic"

  s.files       = Dir.glob("{lib,spec}/**/*.rb")

  s.add_dependency "nokogiri"
end
