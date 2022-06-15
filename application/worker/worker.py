import requests
import json
import os

API_URL = "https://api.producthunt.com/v2/api/graphql"

### export API_ACCESS_TOKEN="<access_token_value>"
API_ACCESS_TOKEN = os.getenv("API_ACCESS_TOKEN")

headers = {
"Accept": "application/json",
"Content-Type": "application/json",
"Authorization": "Bearer " + API_ACCESS_TOKEN,
"Host": "api.producthunt.com"
}

query = {"query":
        """
        query todayPosts {
            posts(order: VOTES, first: 20){
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
        """}

response = requests.post(API_URL,
						 headers=headers,
						 data=json.dumps(query))

### Verify Status Code
print(response.status_code)

with open('response.json', 'w') as response_file:
    json.dump(response.json(), response_file, indent=4)
