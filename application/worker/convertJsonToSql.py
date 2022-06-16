import sqlizer
import os

### ###
### Using this script, the 'posts.json' file will be converted to SQL in a new file name 'posts.sql'.
### ###

### At first, store your Access Token (API_KEY) as a environment variable in your OS by doing so:
### export API_KEY="<api_key_value>"
sqlizer.config.API_KEY = os.getenv("API_KEY")

### Convert JSON to SQL
with open('posts.json', 'rb') as file_content:
    converter = sqlizer.File(file_content, sqlizer.DatabaseType.PostgreSQL, sqlizer.FileType.JSON, 'posts.json', 'posts')
    converter.convert(wait=True)
    with open('posts.sql', 'w') as output_file:
        output_file.write(converter.download_result_file().text)
