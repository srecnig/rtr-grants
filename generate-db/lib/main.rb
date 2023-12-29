# frozen_string_literal: true

require 'json'
require_relative 'parser'

def main(table_name, in_path, out_path)
  out_name = File.basename(in_path, '.json')
  data = JSON.parse(File.read(in_path))
  parser = RtrDataParser::Parser.new(data, table_name)

  File.write("#{out_path}/#{out_name}-create-table.sql", parser.create_table_sqlite)
  File.open("#{out_path}/#{out_name}-insert-into.sql", 'w') do |file|
    parser.insert_sqlite.each { |statement| file.puts(statement) }
  end
end

main('rtr_data', 'data/2023-12-29.json', 'out/')
