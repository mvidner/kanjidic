#!/usr/bin/env ruby

$:.unshift "../lib"
require "kanjidic"

if ARGV[0] == "-l"
  d = Marshal.load(File.read("/tmp/kanjidic.rbdump"))
else
  if ARGV[0] == "-s"
    puts "smaller kanjidic"
    d = Kanjidic.new(File.expand_path("../../kanjidic2-sample.xml", __FILE__))
  else
    d = Kanjidic.new
  end

  File.open "/tmp/kanjidic.rbdump.new", "w" do |f|
    Marshal.dump(d,f)
  end
end

kyouiku = d.all.find_all {|k| k.grade <= 6 }
by_on = {}
kyouiku.each do |k|
  k.ja_on.each do |on|
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
