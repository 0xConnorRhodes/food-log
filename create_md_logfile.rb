#!/usr/bin/env ruby
require 'erb'
require 'date'
require 'fileutils'

date_str = Date.today.strftime("%y%m%d")
remaining = 2000
consumed = 0

template_path = File.join(File.dirname(__FILE__), "cb_note-template.erb")
template = File.read(template_path)

renderer = ERB.new(template)
content = renderer.result(binding)

notes_dir = File.expand_path("~/notes/s")

file_name = "cal_budget-#{date_str}.md"
file_path = File.join(notes_dir, file_name)

File.write(file_path, content)
