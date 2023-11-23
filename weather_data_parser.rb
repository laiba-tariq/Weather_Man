# frozen_string_literal: true

require 'csv'
require 'date'

class WeatherDataParser
  def self.parse(file_path)
    folder_name = file_path.split('_')[0].split('/')[1]  # fetch the folder name
    weather_data = []

    total_lines = File.foreach(file_path).count

    line_number = 0
    CSV.foreach(file_path, headers: true, skip_blanks: true) do |row|
      line_number += 1
      next if folder_name == 'lahore' && line_number == total_lines

      if folder_name == 'Dubai'
        date = row['GST']
      elsif %w[lahore Murree].include?(folder_name)
        date = row['PKT']
      end

      max_humidity = row['Max Humidity']
      max_temp = row['Max TemperatureC']
      min_temp = row['Min TemperatureC']

      max_temp_value = max_temp&.to_i
      min_temp_value = min_temp&.to_i
      max_humidity_value = max_humidity.nil? ? '' : max_humidity.to_i

      begin
        date_value = date.nil? ? '' : Date.parse(date)
        weather_data << { date: date_value.to_s, max_humidity: max_humidity_value, max_temperature: max_temp_value,
                          min_temperature: min_temp_value }
      rescue Date::Error
        weather_data << { date: nil, max_humidity: max_humidity_value, max_temperature: max_temp,
                          min_temperature: min_temp }
      end
    end
    weather_data
  end
end
