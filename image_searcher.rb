# Class responsible for searching image files in a directory and see if they match with the parsed content.
class ImageSearcher
  IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.bmp', '.svg'].freeze

  # Initializes an ImageSearcher object.
  #
  # @param parser [Object] The parser object responsible for parsing image content.
  # @param debug [Boolean] Flag indicating whether debug mode is enabled or not.
  def initialize(parser, debug)
    @parser = parser
    @debug = debug
  end

  # Method to search for image files in a directory and parse them.
  #
  # @param directory [String] The directory path where image files are located.
  # @param keyword [String] The keyword to search for in the content of image files.
  def search_files_in_directory(directory, keyword)
    unless Dir.exist?(directory)
      puts "Error: The specified directory '#{directory}' does not exist."
      return
    end

    images = Dir.glob(File.join(directory, '*')).select { |file| file_image?(file) }
    display_image_count(images.size)
    process_images(images, keyword)
  end

  private

  # Checks if a file has an image extension.
  #
  # @param file [String] The file path to check.
  # @return [Boolean] True if the file has an image extension, otherwise false.
  def file_image?(file)
    IMAGE_EXTENSIONS.include?(File.extname(file).downcase)
  end

  # Invokes processing of each image file.
  #
  # @param images [Array<String>] An array of file paths to image files.
  # @param keyword [String] The keyword to search for in the content of the image.
  def process_images(images, keyword)
    images.each_with_index do |image_fullpath, index|
      image_count = index + 1
      puts "#{image_count}| Parsing #{image_fullpath}"
      process_image(image_fullpath, keyword)
    end
  end

  # Performs the content analysis of an image.
  #
  # @param image_fullpath [String] The full path of the image file to parse.
  # @param keyword [String] The keyword to search for in the content of image files.
  def process_image(image_fullpath, keyword)
    image_parse_response = @parser.parse(image_fullpath)
    return if image_parse_response.nil?

    puts "DEBUG: Image description: #{image_parse_response}" if @debug
    image_matches?(image_parse_response, keyword)
  end

  # Displays the number of image files found in the directory.
  #
  # @param count [Integer] The count of image files found.
  def display_image_count(count)
    if count.zero?
      puts 'No image files found in the directory.'
      return
    else
      puts "Number of image files found: #{count}"
    end
  end

  # Searches for a multi-word keyword within the word list.
  #
  # @param word_list [Array<String>] The list of words from the image content.
  # @param keyword [String] The keyword to search for in the content of image files.
  # @return [Boolean] True if the keyword is found, otherwise false.
  def search_multiple_word(word_list, keyword)
    index = word_list.index(keyword.split[0])
    if index.nil?
      puts "DEBUG: multiple word not found."
    else
      puts "DEBUG: First word found at index: #{index}" if @debug
      shift = 0
      keyword.split.each do |word|
        index_shifted = shift + index
        if word.downcase == word_list[index_shifted].downcase
          shift += 1
        else
          return false
        end
      end
      return true
    end
  end

  # Checks if the image content matches the keyword.
  #
  # @param image_parse_response [String] The parsed content of the image.
  # @param keyword [String] The keyword to search for in the content of image files.
  def image_matches?(image_parse_response, keyword)
    puts "DEBUG: Searching for '#{keyword}' and '#{keyword.en.plural}'" if @debug
    word_list = image_parse_response.downcase.split(/\W+|\b'/)
    if keyword.index(' ').nil?
      puts "DEBUG: keyword is a single word." if @debug
      if word_list.include?(keyword)
        display_match(image_parse_response, keyword, false)
      elsif word_list.include?(keyword.en.plural)
        display_match(image_parse_response, keyword, true)
      end
    else
      found = search_multiple_word(word_list, keyword)
      if found
        display_match(image_parse_response, keyword, false)
      else
        found = search_multiple_word(word_list, keyword.en.plural)
        display_match(image_parse_response, keyword, true) if found
      end
    end
  end

  # Displays the content of the image, indicating if the match was with the plural form of the keyword.
  #
  # @param content [String] The parsed content of the image.
  # @param keyword [String] The keyword to search for in the content of image files.
  # @param plural [Boolean] Flag indicating if the keyword is in plural form.
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

  # Displays the content of the image with colorized keyword.
  #
  # @param phrase [String] The content of the image.
  # @param keyword [String] The keyword to search for in the content of image files.
  # @param color_code [String] The color code for highlighting the keyword, default green
  def display_string_colorized(phrase, keyword, color_code="\e[32m")
    output = "=> "
    words = phrase.split(/\s+/)
    keyword_words = keyword.split(/\s+/)

    words.each do |word|
      if keyword_words.any? { |kw| word.downcase == kw.downcase }
        output += "#{color_code}#{word}\e[0m "
      else
        output += "#{word} "
      end
    end

    puts output.strip
  end
end
