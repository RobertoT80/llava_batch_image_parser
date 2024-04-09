# Class responsible for searching image files in a directory and see if they match with the parsed content.
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
    process_images(images, keyword)
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

    puts "DEBUG: Image description: #{image_parse_response}" if @debug
    image_matches?(image_parse_response, keyword)
  end

  # Displays how many images have been found, if any.
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

  def search_multiple_word(word_list, keyword)
    puts "DEBUG: keyword is #{keyword.split.count} words" if @debug
    index = word_list.index(keyword.split[0])
    if index.nil?
      puts "DEBUG: multiple word not found."
    else
      puts "DEBUG: First word found at index: #{index}" if @debug
      shift = 0
      # singular
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

  # Method to return if an image matches.
  #
  # @param image_parse_response [String] The parsed content of the image.
  # @param keyword [String] The keyword to search for in the content of image files.
  def image_matches?(image_parse_response, keyword)
    puts "DEBUG: Searching for '#{keyword}' and '#{keyword.en.plural}'" if @debug
    # I want all words removing the punctuation if present at the end except if it's an apostrophe
	word_list = image_parse_response.downcase.split(/\W+|\b'/)
	puts "word_list: #{word_list}" if @debug
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