Ruby script that leverages a 7b multimodal AI to batch scan for content in all images in a local folder. It will display you the content of an image whose content matches the keyword passed, which must be a singular noun in english language (its plural form will be searched as well).

You need 'ollama' with the 'llava' multimodal model installed on your machine.
It must be serving requests via the API endpoint specified in API_URL in config.rb which can be changed if needed.

Example to run and search for images of "cat" or "cats" in your photos dir:  
ruby main.rb c:/photos/ cat  

To search in subfolders as well, add -recurse:  
ruby main.rb c:/photos/ cat -recurse  

There is also a -debug parameter which shows the image description if it doesn't matches:  
ruby main.rb c:/photos/ cat -debug  

To search for a keyword which is made of more than one word, such as "washing machine", make sure to wrap the parameter in quote i.e.:  
ruby main.rb c:/photos/ 'washing machine'  

