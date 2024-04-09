# Uses llava multimodal AI to batch scan content in images in a local folder and display what matches a specific keyword.
# Ensure that 'ollama' with the 'llama' multimodal model is installed.
# It must be serving requests via the API endpoint specified in the constant API_URL in config.rb.

# Author:: Roberto Toso
# License: Apache License 2.0

# Params:
# [0]:: the patch where to search for images (i.e. c:/photos/)
# [1]:: what to search in the content of the image (i.e. 'cat' which will also search for 'cats')

require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'linguistics'
Linguistics.use :en

require_relative 'image_parser'
require_relative 'image_searcher'
require_relative 'config'
require_relative 'metadata'

class Main
  def initialize(debug = false)
    puts "#{PROGRAM_NAME} #{PROGRAM_VERSION} started at: #{Time.now}"

    @parser = ImageParser.new(API_URL, debug)
    @debug = debug
    @start_time = Time.now
  end

  # Wrapper which validates the inputs and starts the search
  def init_search(directory, keyword, recurse)
    validate_arguments(directory, keyword)
    search_images_in_directory(directory, keyword, recurse)
  end

  private

  # Validates the command-line arguments
  def validate_arguments(directory, keyword)
    unless directory && keyword
      puts 'Error: Please provide directory path and keyword.'
      usage
    end
  end

  def display_total_time()
    total_time_seconds = (Time.now - @start_time).to_i
    if total_time_seconds >= 60
      total_time_minutes = total_time_seconds / 60
      remaining_seconds = total_time_seconds % 60
      if remaining_seconds.zero?
        puts "Total time taken: #{total_time_minutes} minutes"
      else
        puts "Total time taken: #{total_time_minutes} minutes and #{remaining_seconds} seconds"
      end
    else
      puts "Total time taken: #{total_time_seconds} seconds"
    end
  end

  # Instantiates the ImageSearcher class for each directory to scan
  def search_images_in_directory(directory, keyword, recurse)
    directory = directory.gsub("\\", "/")
    search = ImageSearcher.new(@parser, @debug)
    puts "=== Searching in root directory: #{directory} ==="
    search.search_files_in_directory(directory, keyword)
    if recurse
      Dir.glob("#{directory}/*").each do |dir|
        next unless File.directory?(dir)
        puts
        puts "=== Searching in subdir: #{dir} ==="
        search.search_files_in_directory(dir, keyword)
      end
    end
    display_total_time
  end

  def usage
    puts 'Usage: ruby main.rb <directory_with_images> <keyword_to_search> [-debug] [-recurse]'
    exit
  end
end

args = ARGV
debug = args.include?("-debug")
recurse = args.include?("-recurse")
args.reject! { |arg| arg == "-debug" || arg == "-recurse" }

Main.new(debug).init_search(args[0], args[1], recurse)
