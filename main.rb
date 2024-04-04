# Ensure that 'ollama' with the 'llama' multimodal model is installed.
# It must be serving requests via the API endpoint specified in the constant API_URL in config.rb.

# Author:: Roberto Toso
# Copyright:: Copyright (c) 2024

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

# Main class responsible for orchestrating the image search process.
class Main
  def initialize
    puts "#{PROGRAM_NAME} #{PROGRAM_VERSION} started at: #{Time.now}"
    @parser = ImageParser.new(API_URL)
  end

  # Method to start the image search process.
  def start_search(directory, keyword)
    validate_arguments(directory, keyword)
    perform_image_search(directory, keyword)
  end

  private

  # Method to validate the command-line arguments.
  def validate_arguments(directory, keyword)
    unless directory && keyword
      puts 'Error: Please provide directory path and keyword.'
      usage
    end
  end

  # Method to perform the image search.
  def perform_image_search(directory, keyword)
    search = ImageSearcher.new(@parser)
    search.search_files_in_directory(directory, keyword)
  end

  # Method to display usage instructions.
  def usage
    puts 'Usage: ruby main.rb <directory_with_images> <keyword_to_search>'
    exit
  end
end

Main.new.start_search(ARGV[0], ARGV[1])
