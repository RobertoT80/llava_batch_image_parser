Ruby script that leverages a 7b multimodal AI to batch scan for content in all images in a local folder. It will display you the content of an image which contains the object passed as a keyword, which must be a singular noun in english language (its plural form will be searched as well).

You need 'ollama' with the 'llava' multimodal model installed on your machine.
It must be serving requests via the API endpoint specified in API_URL in config.rb which can be changed if needed.

Example to run and search for images of "cat" or "cats" in your photos dir:
ruby main.rb c:/photos/ cat
To search for a keyword which is made of more than one word, such as "washing machine", make sure to wrap the parameter in quote i.e.:
ruby main.rb c:/photos/ 'washing machine'

The program also allows to run in debug mode by adding -debug, which for now, only shows the pluralized version of the string which you are searching, so you can double check it's been pluralized correctly.
ruby main.rb c:/photos/ 'washing machine' -debug
