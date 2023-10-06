import json
import requests

SESSION_COOKIE = ""

batches = {}
cities = {}
page_num = 1

while True:
    response = requests.get(f"https://kitt.lewagon.com/api/v1/users?page={page_num}", cookies={"_kitt2017_": SESSION_COOKIE})
    
    data = json.loads(response.content)
    
    for user in data["users"]:
        user_data = user.get("alumnus", {})
        user_camp_slug = user_data.get("camp_slug")
        
        # If user data is empty or not valid, skip this user
        if user_camp_slug is None or not user_camp_slug.isdigit() or int(user_camp_slug) == 0:
            continue
            
        batch_city = user_data.get("city")
        batch_number = int(user_camp_slug)
        batch_year = int(f"20{user_data.get('camp_date')[-2:]}")

        batch_key = (batch_number, batch_city, batch_year)

        if batch_city in cities:
            cities[batch_city] += 1 
        else:
            cities[batch_city] = 1

        if batch_key in batches:
            batches[batch_key] += 1
        else:
            batches[batch_key] = 1

    if not data["has_more"]:
        break
    
    page_num += 1
