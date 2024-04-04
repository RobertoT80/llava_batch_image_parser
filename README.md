Uses llava multimodal AI to batch scan content in images in a local folder and display what matches a specific keyword.

You need 'ollama' with the 'llama' multimodal model installed.
It must be serving requests via the API endpoint specified in the constant API_URL in config.rb which can be changed if needed.

Example to run and search for images of "cat" or "cats" (the pluralized noun will also be accounted for) in your photos dir:
ruby main.rb c:/photos/ cat
