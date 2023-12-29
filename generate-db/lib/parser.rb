# frozen_string_literal: true

require 'json'

module RtrDataParser
  class Parser
    def initialize(json_data, table_name)
      raise 'Wrong data format - must contain data key' unless json_data.key?('data')

      @data = json_data['data']
      @table_name = table_name
      complete_dp = @data.find { |dp| dp.values.none?(&:nil?) }
      raise 'No complete data point found' unless complete_dp

      type_mapping = {
        'Integer' => 'INTEGER',
        'Float' => 'DECIMAL',
        'String' => 'VARCHAR'
      }

      @columns = complete_dp.each.with_object({}) do |(k, v), dict|
        dict[k] = type_mapping[v.class.to_s]
      end
    end

    def create_table_sqlite
      statement = "CREATE TABLE #{@table_name} ("
      statement += @columns.map { |column, data_type| "#{column} #{data_type}" }.join(', ')
      statement += ');'
      statement
    end

    def insert_sqlite
      @data.each.with_object([]) do |row, statements|
        normalized_row = row.each.map do |column, value|
          next [column, 'NULL'] if value.nil?

          case @columns[column]
          when 'INTEGER', 'DECIMAL'
            [column, value]
          when 'VARCHAR'
            quoted_value = value.gsub("'", "''") # dangerous! not sure if this is enough!
            [column, "'#{quoted_value}'"]
          else
            raise "Unknown data type #{@columns[column]}"
          end
        end
        normalized_row = normalized_row.to_h
        statement = "INSERT INTO #{@table_name} (#{normalized_row.keys.join(', ')}) " \
                    "VALUES (#{normalized_row.values.join(', ')});"
        statements << statement
      end
    end
  end
end
