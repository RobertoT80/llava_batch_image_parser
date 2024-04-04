Ruby script that leverages a 7b multimodal AI to batch scan for content in all images in a local folder. It will display you the content of an image where the keyword passed, which must be a singular noun in english language, will be found (also accounting for its plural form).

You need 'ollama' with the 'llama' multimodal model installed on your machine.
It must be serving requests via the API endpoint specified in API_URL in config.rb which can be changed if needed.

Example to run and search for images of "cat" or "cats" in your photos dir:
ruby main.rb c:/photos/ cat
