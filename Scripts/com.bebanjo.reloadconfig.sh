#!/usr/bin/env ruby
require 'pathname'

puts "\n== Reloading config files from examples =="

examples = Dir['config/*.yml.example']
config_files = examples.map { |file| file.sub '.example', '' }

examples.zip(config_files).each do |example, config_file|
  system "cp -f #{example} #{config_file}"
end
