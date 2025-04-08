#!/usr/bin/env ruby
# build food database from markdown notes

require_relative 'config'

# Function to remove units and convert to integer if possible.
def convert_value(val)
  # Remove any trailing units (g|mg) and convert to integer if possible.
  if val.strip =~ /^(\d+)(g|mg)?$/
    $1.to_i
  else
    val.strip
  end
end

# Iterate over food log markdown files
Dir.glob(File.join($notes_dir, "**", "fl_*.md")).each do |md_file|
  file_content = File.read(md_file)
  file_down = file_content.downcase

  # Find the nutrition facts header (h1) and macros header (h2)
  nutrition_index = file_down.index("# nutrition facts")
  macros_index = file_down.index("## macros")
  # Only process if file contains both headings and macros is inside nutrition facts
  next unless nutrition_index && macros_index && macros_index > nutrition_index
  
  macros_data = {}
  current_parent = nil
  in_macros = false
  
  File.foreach(md_file) do |line|
    # When in the macros section, stop if we see a new h1 or h2 heading.
    if in_macros && line.strip =~ /^#{'#'}{1,2}\s+\S/
      break
    end

    # When we see the "## Macros" header, start processing.
    if !in_macros && line =~ /^##\s+Macros/i
      in_macros = true
      next
    end

    next unless in_macros

    # Process bullet list items (top-level and nested).
    # Match a bullet: optionally indented, a dash, then key colon value.
    if line =~ /^(\s*)-\s*([^:]+):\s*(.*)$/
      indent_chars = $1
      key = $2.strip.downcase
      value = $3.strip
      
      # Top-level bullet (minimal indent) starts a new key.
      if indent_chars == "" # if no whitespace character before the bullet, interpret as top-level item
        if value.empty?
          macros_data[key] = {}
          current_parent = key
        else
          macros_data[key] = convert_value(value)
          current_parent = nil
        end
      else
        # Nested bullet. Only add if a top-level key exists for nesting.
        if current_parent && macros_data[current_parent].is_a?(Hash)
          macros_data[current_parent][key] = convert_value(value)
        end
      end
    end
  end
  
  # Skip file if we didn't capture any macros data.
  next if macros_data.empty?

  # Build a clean filename from the markdown file.
  lean_name = File.basename(md_file, ".md").sub(/^fl_/, '')
  
  # Insert the food name (lean_name) into the output_data
  output_data = { "name" => lean_name }.merge(macros_data)

  # Write output_data as binary to file in $food_data_dir
  # note that this will overwrite existing files
  output_file = File.join($food_data_dir, "#{lean_name}.bin")
  File.open(output_file, "wb") do |f|
    f.write(Marshal.dump(output_data))
  end

  puts "wrote file for #{md_file} -> #{output_file}"
end
