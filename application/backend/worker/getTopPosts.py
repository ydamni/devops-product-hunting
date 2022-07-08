import requests
import json
import os

### ###
### Using this script, the top 500 most voted posts on Product Hunt will be stored in the file 'posts.json'.
### ###

def show_response_status(response, type_of_response):
    if response.status_code == 200:
        print("OK - " + type_of_response + " received.")
    else:
        print("ALERT - " + type_of_response + " not received - Code " + response.status_code)
        print("The script is stopping.")
        exit(1)


if __name__ == '__main__':
    ### Add '[' (with indentation) at start of posts.json file
    with open('posts.json', 'w') as posts_file:
        posts_file.write('            [\n')

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
    NUM_QUERIES = 25
    for i in range(NUM_QUERIES):
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
        show_response_status(response, "Data")

        ### Store Response inside response.json file
        with open('response.json', 'w') as response_file:
            json.dump(response.json(), response_file, indent=4)

        ### Put response.json file content into variable with multiple lines
        with open('response.json', 'r') as response_file:
            response_lines = response_file.read().splitlines(True)

        ### Until the last query
        if i != NUM_QUERIES:
            ### Add a comma (with indentation) at the last node
            response_lines[-5] = '                },'

        ### Cut first & last 4 lines of response to keep only nodes
        with open('posts.json', 'a') as posts_file:
            posts_file.writelines(response_lines[4:-4])


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

        ### Show Response Status
        show_response_status(cursor_response, "Cursor")

        ### Store cursor value
        CURSOR = cursor_response.json()['data']['posts']['pageInfo']['endCursor']

    ### Add ']' (with indentation) at the end of posts.json file
    with open('posts.json', 'a') as posts_file:
        posts_file.write('            ]')

    ### Delete response.json file
    if os.path.exists("response.json"):
        os.remove("response.json")
