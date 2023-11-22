require 'optparse'  # used for option_parser to parse the input from command line agrs
require 'date'
require 'csv'
require 'pry'   #used for debugging
require 'colorize' # used in chart colors

def parse_weather_data(file_path)
  folder_name = file_path.split('_')[0].split('/')[1]  # fetch the folder name
  weather_data = []

  total_lines = File.foreach(file_path).count

  line_number = 0
  CSV.foreach(file_path, headers: true, skip_blanks: true) do |row|
    line_number += 1
    next if folder_name == 'lahore' && line_number == total_lines

    if folder_name == 'Dubai'
      date = row['GST']
    elsif folder_name == 'lahore' || folder_name == 'Murree'
      date = row['PKT']
    end

    max_humidity = row['Max Humidity']
    max_temp = row['Max TemperatureC']
    min_temp = row['Min TemperatureC']

    max_temp_value = max_temp.nil? ? nil : max_temp.to_i
    min_temp_value = min_temp.nil? ? nil : min_temp.to_i
    max_humidity_value = max_humidity.nil? ? "" : max_humidity.to_i

    begin
      date_value = date.nil? ? "" : Date.parse(date)
      weather_data << { date: date_value.to_s, max_humidity: max_humidity_value, max_temperature: max_temp_value, min_temperature: min_temp_value }
    rescue Date::Error
      weather_data << { date: nil, max_humidity: max_humidity_value, max_temperature: max_temp, min_temperature: min_temp }
    end
  end
  weather_data
end

def generate_yearly_report(data, year)
  year_data = data.reject do |entry|   # ignore all values which are other than specified year
    entry_date = entry[:date]

    if entry_date.nil?
      true
    else
      begin
        parsed_date = Date.parse(entry_date).year!=year
      rescue Date::Error
        true
      end
    end
  end
  unless year_data.empty?

    highest_temp = year_data.max_by { |entry| entry[:max_temperature].to_f }
    lowest_temp = year_data.select { |entry| !entry[:min_temperature].nil? }.min_by { |entry| entry[:min_temperature].to_f }
    most_humid = year_data.max_by { |entry| entry[:max_humidity].to_i }
    puts "Highest: #{highest_temp[:max_temperature]}C on #{Date.parse(highest_temp[:date]).strftime('%B %d')}"
    puts "Lowest: #{lowest_temp[:min_temperature]}C on #{Date.parse(lowest_temp[:date]).strftime('%B %d')}"
    puts "Humid: #{most_humid[:max_humidity]}% on #{Date.parse(most_humid[:date]).strftime('%B %d')}"
  else
    puts "No valid data available for the specified year #{year}."
  end
end
def generate_monthly_report(data, year, month)
  month_data = data.reject do |entry|
    entry_date = entry[:date]

    if entry_date.nil?
      true
    else
      begin
        parsed_date = Date.parse(entry_date)
        parsed_date.year != year  || parsed_date.month != month
      rescue Date::Error
        true
      end
    end
  end
  unless month_data.empty?
    avg_highest_temp = month_data.map { |entry| entry[:max_temperature].to_f }.reduce(:+) / month_data.length
    avg_lowest_temp = month_data.map { |entry| entry[:min_temperature].to_f }.reduce(:+) / month_data.length
    avg_humidity = month_data.map { |entry| entry[:max_humidity].to_i }.reduce(:+) / month_data.length

    puts "Highest Average: #{avg_highest_temp.round(2)}C"
    puts "Lowest Average: #{avg_lowest_temp.round(2)}C"
    puts "Average Humidity: #{avg_humidity.round(2)}%"
  else
    puts "No data available for the specified month #{Date.new(year, month, 1).strftime('%B %Y')}."
  end
end
def generate_chart(data, year, month)
  year_month_data = data.reject do |entry|
    entry_date = entry[:date]

    if entry_date.nil?
      true
    else
      begin
        parsed_date = Date.parse(entry_date)
        parsed_date.year != year || parsed_date.month != month
      rescue Date::Error
        true
      end
    end
  end
  unless year_month_data.empty?
    puts "#{Date.new(year, month, 1).strftime('%B %Y')}"

    year_month_data.each do |entry|
      day = Date.parse(entry[:date]).day
      highest_temp = entry[:max_temperature]
      lowest_temp = entry[:min_temperature]
      puts "#{day}".colorize(:white) +"#{'+' * highest_temp}".colorize(:red)+"#{highest_temp}C".colorize(:white)
      puts "#{day}".colorize(:white) +"#{'+' * lowest_temp}".colorize(:blue) +" #{lowest_temp}C".colorize(:white)
    end
  end
end
def generate_chart_oneLine(data, year, month)
  year_month_data = data.reject do |entry|
    entry_date = entry[:date]

    if entry_date.nil?
      true
    else
      begin
        parsed_date = Date.parse(entry_date)
        parsed_date.year != year || parsed_date.month != month
      rescue Date::Error
        true
      end
    end
  end
  unless year_month_data.empty?
    puts "#{Date.new(year, month, 1).strftime('%B %Y')}"

    year_month_data.each do |entry|
      day = Date.parse(entry[:date]).day
      highest_temp = entry[:max_temperature]
      lowest_temp = entry[:min_temperature]
      puts "#{day}".colorize(:white) + "#{'+' * lowest_temp} ".colorize(:blue)+"#{'+' * highest_temp} ".colorize(:red) +"#{lowest_temp}C".colorize(:white) +" - #{highest_temp}C".colorize(:white)
    end
  end
end


#Parser for command line input
options = {}
OptionParser.new do |opts|
  opts.on('-e', '--year YEAR', 'Display highest, lowest, and most humid for the given year') do |year|
    options[:year] = year.to_i
  end

  opts.on('-a', '--average YEAR/MONTH', 'Display average highest, lowest, and humidity for the given month and year') do |month_year|
    options[:year], options[:month] = month_year.split('/').map(&:to_i)
  end

   opts.on('-c', '--chart YEAR/MONTH', 'Draw horizontal bar charts for the given month and year') do |month_year|
     options[:mode] = :chart
     options[:year], options[:month] = month_year.split('/').map(&:to_i)
   end
end.parse!


files_folder = ARGV.last
files = Dir.glob(File.join(files_folder, '*.txt'))

 weather_data = files.flat_map { |file| parse_weather_data(file)}
 if options[:year] && !options[:month]
  generate_yearly_report(weather_data, options[:year])
 elsif options[:month] && options[:year] && !options[:mode]
  generate_monthly_report(weather_data, options[:year], options[:month])
  elsif options[:month] && options[:year] && options[:mode] ==:chart
    generate_chart(weather_data, options[:year], options[:month])
    puts "----------------------------BONUS TASK------------------------------------\n"
    generate_chart_oneLine(weather_data, options[:year], options[:month])
end
