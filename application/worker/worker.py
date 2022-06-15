import requests
import json
import os

### ###
### Using this script, the top 500 most voted posts on Product Hunt will be stored in the file 'list_posts.json'.
### ###

### Delete existing list_posts.json file
if os.path.exists("list_posts.json"):
  os.remove("list_posts.json")

API_URL = "https://api.producthunt.com/v2/api/graphql"

### At first, store your Access Token as a environment variable in your OS by doing so:
### export API_ACCESS_TOKEN="<access_token_value>"
API_ACCESS_TOKEN = os.getenv("API_ACCESS_TOKEN")

headers = {
"Accept": "application/json",
"Content-Type": "application/json",
"Authorization": "Bearer " + API_ACCESS_TOKEN,
"Host": "api.producthunt.com"
}

### Used by GraphQL for pagination - Necessary for multiple queries
CURSOR = ""

### By default, Product Hunt API v2 returns 20 posts maximum per query
### In order to retrieve 500 posts, The API must be queried 25 times (20*25=500).
for i in range(25):
    i+=1

    ### ###
    ### GET TOP POSTS
    ### ###

    ### Store query inside string variable to replace cursor value with replace()
    string_query = """
            query {
                posts(order: VOTES, first: 20, after: "$cursor"){
                    edges {
                        node {
                            name,
                            createdAt,
                            votesCount,
                            reviewsRating,
                            tagline,
                            description,
                            url
                        }
                    }
                }
            }
            """

    ### Store string_query inside Python dict variable 'query' while replacing cursor value
    query = {"query":
    string_query.replace("$cursor", CURSOR)}

    ### Send Request and store Response
    response = requests.post(API_URL,
                                    headers=headers,
                                    data=json.dumps(query))

    ### Show Response Status
    if response.status_code == 200:
        print("OK - Data received.")
    else:
        print("ALERT - Data not received - Code", response.status_code)
        print("The script is stopping.")
        exit()

    ### Store Response inside response.json file
    with open('response.json', 'w') as response_file:
        json.dump(response.json(), response_file, indent=4)

    ### Put response.json file content into variable
    with open('response.json', 'r') as response_file:
        response_lines = response_file.read().splitlines(True)

    ### Cut first & last 4 lines of response to keep only nodes
    with open('list_posts.json', 'a') as list_posts_file:
        list_posts_file.writelines(response_lines[4:-4])

    ### ###
    ### GET CURSOR
    ### ###

    ### Store cursor query inside string to replace with replace()
    string_cursor_query = """
                        query {
                            posts(order: VOTES, first: 20, after: "$cursor"){
                                pageInfo {
                                    endCursor
                                }
                            }
                        }
                        """

    ### Store cursor query inside Python dict variable for API Request
    cursor_query = {"query":
    string_cursor_query.replace("$cursor", CURSOR)}

    ### Send Request and store Response
    cursor_response = requests.post(API_URL,
                                    headers=headers,
                                    data=json.dumps(cursor_query))

    ### Show Cursor Response Status
    if cursor_response.status_code == 200:
        print("OK - Cursor received.")
    else:
        print("ALERT - Cursor not received - Code", cursor_response.status_code)
        print("The script is stopping.")
        exit()

    CURSOR = cursor_response.json()['data']['posts']['pageInfo']['endCursor']
