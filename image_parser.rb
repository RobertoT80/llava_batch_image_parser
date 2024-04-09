# Class responsible for parsing images using the specified API endpoint.
class ImageParser
  # Initializes an ImageParser object with the provided API URL.
  #
  # @param api_url [String] The URL of the API endpoint for parsing images.
  # @param debug [Boolean] Flag to enable/disable debug mode.
  def initialize(api_url, debug)
    @api_url = api_url
    @debug = debug
  end

  # Parses the image using the specified model and prompt.
  #
  # @param image_fullpath [String] The full path of the image file to parse.
  # @param model [String] The model to use for parsing the image (default is 'llava').
  # @param prompt [String] The prompt to use for parsing the image (default is 'What is in this picture?').
  # @return [String, nil] The parsed content of the image, or nil if parsing fails.
  def parse(image_fullpath, model = 'llava', prompt = LLAVA_PROMPT)
    uri = URI(@api_url)
    image_content_encoded = encode_image(image_fullpath)
    request = create_request(uri, model, prompt, image_content_encoded)
    send_request(uri, request)
  rescue StandardError => e
    puts "Error occurred during HTTP request: #{e.message}"
    nil
  end

  private

  # Encodes the image file content to Base64.
  #
  # @param image_fullpath [String] The full path of the image file.
  # @return [String] The Base64-encoded image content.
  def encode_image(image_fullpath)
    image_content = File.binread(image_fullpath)
    Base64.strict_encode64(image_content)
  end

  # Creates an HTTP POST request.
  #
  # @param uri [URI] The URI object representing the API endpoint.
  # @param model [String] The model to use for parsing the image.
  # @param prompt [String] The prompt to use for parsing the image.
  # @param image_content_encoded [String] The Base64-encoded image content.
  # @return [Net::HTTP::Post] The HTTP POST request object.
  def create_request(uri, model, prompt, image_content_encoded)
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({
                               model: model,
                               prompt: prompt,
                               stream: false,
                               images: [image_content_encoded]
                             })
    request
  end

  # Sends the HTTP request and handles the response.
  #
  # @param uri [URI] The URI object representing the API endpoint.
  # @param request [Net::HTTP::Post] The HTTP POST request object.
  # @return [String, nil] The parsed content of the image, or nil if parsing fails.
  def send_request(uri, request)
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.read_timeout = 120
      http.request(request)
    end

    handle_response(response)
  end

  # Handles the HTTP response
  #
  # @param response [Net::HTTPResponse] The HTTP response object.
  # @return [String, nil] The parsed content of the image, or nil if parsing fails.
  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      content = parsed_response['response']
      return content unless content.nil?

      puts 'No content found in response.'
    else
      puts "HTTP request failed: #{response.code} #{response.message}"
      nil
    end
  end
end