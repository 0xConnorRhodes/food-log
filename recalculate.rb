#!/usr/bin/env ruby
require 'date'
require 'fileutils'
require 'toml'

date_str = Date.today.strftime("%y%m%d")
notes_dir = File.expand_path("~/notes/s")
file_name = "cal_budget-#{date_str}.md"
file_path = File.join(notes_dir, file_name)

begin
  config = TOML.load_file((File.join(File.dirname(__FILE__), "config.toml")))
  daily_calories = config['daily_calories']
rescue StandardError => e
  puts "Error reading config file: #{e.message}"
  puts "Check #{config_path}"
  exit 1
end

lines = File.readlines(file_path)

remaining_line_index = lines.find_index { |line| line =~ /^- remaining:\s*\d+/ }
consumed_line_index  = lines.find_index { |line| line =~ /^- consumed:\s*\d+/ }
log_heading_index    = lines.find_index { |line| line.strip == "# Log" }

if remaining_line_index.nil? || consumed_line_index.nil? || log_heading_index.nil?
  puts "File format not as expected."
  exit 1
end

consumed = 0
lines[log_heading_index+1..].each do |line|
  consumed += line.split(':')[1].to_i
end

remaining = daily_calories - consumed

lines[remaining_line_index] = "- remaining: #{remaining}\n"
lines[consumed_line_index] = "- consumed: #{consumed}\n"

File.write(file_path, lines.join)
puts "Recalculated macros. Updated log file at #{file_path}." 