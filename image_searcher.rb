# Class responsible for searching image files in a directory and parsing them.
class ImageSearcher
  IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg'].freeze

  def initialize(parser, debug)
    @parser = parser
	@debug = debug
  end

  # Method to search for files in a directory and parse image files.
  # @param directory [String] The directory path where image files are located.
  # @param keyword [String] The keyword to search for in the content of image files.
  def search_files_in_directory(directory, keyword)
    unless Dir.exist?(directory)
      puts "Error: The specified directory '#{directory}' does not exist."
      return
    end

    images = Dir.glob(File.join(directory, '*')).select { |file| file_image?(file) }
    display_image_count(images.size)

    start_time = Time.now # Record start time
    process_images(images, keyword)
    display_total_time(start_time)
  end

  private

  # Checks if a file has an image extension.
  # @param file [String] The file path to check.
  # @return [Boolean] True if the file has an image extension, otherwise false.
  def file_image?(file)
    IMAGE_EXTENSIONS.include?(File.extname(file).downcase)
  end

  # Wrapper to invoke processing of each image file.
  #
  # @param images [Array<String>] An array of file paths to image files.
  # @param keyword [String] The keyword to search for in the content of the image
  def process_images(images, keyword)
    images.each_with_index do |image_fullpath, index|
      image_count = index + 1
      puts "#{image_count}| Parsing #{image_fullpath}"
      process_image(image_fullpath, keyword)
    end
  end

  # Does the actual content analysis of the image
  #
  # @param image_fullpath [String] The full path of the image file to parse.
  # @param keyword [String] The keyword to search for in the content of image files.
  def process_image(image_fullpath, keyword)
    image_parse_response = @parser.parse(image_fullpath)
    return if image_parse_response.nil?

    image_matches?(image_parse_response, keyword)
  end

  # Displays how many images have been found, if any.
  #
  # @param count [Integer] The count of image files found.
  def display_image_count(count)
    if count.zero?
      puts 'No image files found in the directory. Exiting.'
      Kernel.exit(0)
    else
      puts "=== Number of image files found: #{count} ==="
    end
  end

  # Method to display the total time taken for processing.
  #
  # @param start_time [Time] The start time of processing.
  def display_total_time(start_time)
    end_time = Time.now
    total_time = (end_time - start_time)
    puts "Total time taken: #{total_time} seconds"
  end

  # Method to return if an image matches.
  #
  # @param image_parse_response [String] The parsed content of the image.
  # @param keyword [String] The keyword to search for in the content of image files.
  def image_matches?(image_parse_response, keyword)
    puts "DEBUG: Searching for '#{keyword}' and '#{keyword.en.plural}'" if @debug
    if image_parse_response.split.include?(keyword)
      display_match(image_parse_response, keyword, false)
    elsif image_parse_response.split.include?(keyword.en.plural)
      display_match(image_parse_response, keyword, true)
    end
  end

  # Displays the content of the image specifying if the match was with the plural form of the keyword
  def display_match(content, keyword, plural)
    if plural
      keyword = keyword.en.plural
      message = "\e[32mMatch found! (pluralized form: #{keyword})\e[0m"
    else
      message = "\e[32mMatch found!\e[0m"
    end
    puts message
    display_string_colorized(content, keyword)
    
  end
  
  def display_string_colorized(phrase, keyword, color_code="\e[32m")
  output = "=> "
  words = phrase.split(/\s+/)
  words.each do |word|
    if word.downcase == keyword.downcase
      output += "#{color_code}#{word}\e[0m "
    else
      output += "#{word} "
    end
  end
  puts output.strip
  puts
end
  
end
