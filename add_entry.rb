#!/usr/bin/env ruby
require 'date'
require 'fileutils'

date_str = Date.today.strftime("%y%m%d")
notes_dir = File.join(ENV['NOTES'], 's')
file_name = "cal_budget-#{date_str}.md"
file_path = File.join(notes_dir, file_name)

unless File.exist?(file_path)
  puts "Log file for today (#{file_path}) does not exist. Please run create_md_logfile.rb first."
  exit 1
end

print "calorie amount: "
calorie = gets.chomp.to_i
print "description: "
description = gets.chomp

lines = File.readlines(file_path)

remaining_line_index = lines.find_index { |line| line =~ /^- remaining:\s*\d+/ }
consumed_line_index  = lines.find_index { |line| line =~ /^- consumed:\s*\d+/ }
log_heading_index    = lines.find_index { |line| line.strip == "# Log" }

if remaining_line_index.nil? || consumed_line_index.nil? || log_heading_index.nil?
  puts "File format not as expected."
  exit 1
end

# Parse current calorie values.
current_remaining = lines[remaining_line_index][/- remaining:\s*(\d+)/, 1].to_i
current_consumed  = lines[consumed_line_index][/- consumed:\s*(\d+)/, 1].to_i

# Calculate the new values.
new_remaining = current_remaining - calorie
new_consumed  = current_consumed + calorie

# Update running calorie totals.
lines[remaining_line_index] = "- remaining: #{new_remaining}\n"
lines[consumed_line_index] = "- consumed: #{new_consumed}\n"

entry_line = "- #{description}: #{calorie}\n"

# Append the new entry under '# Log'.
lines << entry_line

# Write the updated content back to the file.
File.write(file_path, lines.join)
puts "Added food entry. Updated log file at #{file_path}." 
