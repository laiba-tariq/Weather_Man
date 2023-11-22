require 'optparse'
require_relative 'weather_data_parser'
require_relative 'report_generator'


class WeatherAnalyzer
  def self.process_options(options, files_folder)
    files = Dir.glob(File.join(files_folder, '*.txt'))
    weather_data = files.flat_map { |file| WeatherDataParser.parse(file) }

    if options[:year] && !options[:month]
      ReportGenerator.generate_yearly_report(weather_data, options[:year])
    elsif options[:month] && options[:year] && !options[:mode]
      ReportGenerator.generate_monthly_report(weather_data, options[:year], options[:month])
    elsif options[:month] && options[:year] && options[:mode] == :chart
      ReportGenerator.generate_chart(weather_data, options[:year], options[:month])
      puts "----------------------------BONUS TASK------------------------------------\n"
      ReportGenerator.generate_chart_one_line(weather_data, options[:year], options[:month])
    end
  end
end

# Parser for command line input
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
WeatherAnalyzer.process_options(options, files_folder)
