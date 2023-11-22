require 'date'
require 'colorize'

class ReportGenerator
  def self.generate_yearly_report(data, year)
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


  def self.generate_monthly_report(data, year, month)
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

  def self.generate_chart(data, year, month)
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

  
  def self.generate_chart_one_line(data, year, month)
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
end
