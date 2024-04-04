# Class responsible for parsing images using the specified API endpoint.
class ImageParser
  # Initializes an ImageParser object with the provided API URL.
  #
  # @param api_url [String] The URL of the API endpoint for parsing images.
  def initialize(api_url)
    @api_url = api_url
  end

  # Parses the image using the specified model and prompt.
  #
  # @param image_fullpath [String] The full path of the image file to parse.
  # @param model [String] The model to use for parsing the image (default is 'llava').
  # @param prompt [String] The prompt to use for parsing the image (default is 'What is in this picture?').
  # @return [String, nil] The parsed content of the image, or nil if parsing fails.
  def parse(image_fullpath, model = 'llava', prompt = 'What is in this picture?')
    uri = URI(@api_url)
    image_content_encoded = encode_image(image_fullpath)
    request = create_request(uri, model, prompt, image_content_encoded)
    send_request(uri, request)
  rescue StandardError => e
    puts "Error occurred during HTTP request: #{e.message}"
    nil
  end

  private

  def encode_image(image_fullpath)
    image_content = File.binread(image_fullpath)
    Base64.strict_encode64(image_content)
  end

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

  def send_request(uri, request)
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.read_timeout = 120
      http.request(request)
    end

    handle_response(response)
  end

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
