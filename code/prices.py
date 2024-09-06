import os
import sys
import json
import requests
from datetime import datetime, timedelta
from statistics import mean

# eBay API credentials
CLIENT_ID = os.environ.get('EBAY_CLIENT_ID')
CLIENT_SECRET = os.environ.get('EBAY_CLIENT_SECRET')

if not CLIENT_ID or not CLIENT_SECRET:
    print("Error: eBay API credentials not found in environment variables.")
    print("Please set EBAY_CLIENT_ID and EBAY_CLIENT_SECRET in your .env file or environment.")
    sys.exit(1)

# eBay API endpoints
AUTH_URL = 'https://api.ebay.com/identity/v1/oauth2/token'
SEARCH_URL = 'https://api.ebay.com/buy/browse/v1/item_summary/search'

def get_access_token():
    response = requests.post(AUTH_URL, 
        data={'grant_type': 'client_credentials', 'scope': 'https://api.ebay.com/oauth/api_scope'},
        auth=(CLIENT_ID, CLIENT_SECRET))
    response.raise_for_status()
    return response.json()['access_token']

def search_ebay(model, access_token):
    headers = {
        'Authorization': f'Bearer {access_token}',
        'X-EBAY-C-MARKETPLACE-ID': 'EBAY-US'
    }
    params = {
        'q': model,
        'category_ids': '175669',  # Hard Drives category
        'sort': 'price',
        'limit': 5
    }
    response = requests.get(SEARCH_URL, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

def parse_price(price_str):
    return float(price_str.split()[0])

def get_average_price(model):
    cache_file = f'price_cache_{model}.json'
    
    # Check cache
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as f:
            cache = json.load(f)
        if datetime.now() - datetime.fromisoformat(cache['timestamp']) < timedelta(days=1):
            return cache['price']
    
    # Fetch new data
    access_token = get_access_token()
    results = search_ebay(model, access_token)
    
    if 'itemSummaries' not in results:
        print(f"No results found for {model}")
        return None
    
    prices = [parse_price(item['price']['value']) for item in results['itemSummaries']]
    avg_price = mean(prices)
    
    # Update cache
    with open(cache_file, 'w') as f:
        json.dump({'timestamp': datetime.now().isoformat(), 'price': avg_price}, f)
    
    return avg_price

def main(models_file, output_file):
    with open(models_file, 'r') as f:
        models = [line.strip() for line in f]
    
    results = {}
    for model in models:
        try:
            price = get_average_price(model)
            results[model] = price
            print(f"{model}: ${price:.2f}")
        except Exception as e:
            print(f"Error processing {model}: {str(e)}")
    
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python ebay_price_checker.py <models_file> <output_file>")
        sys.exit(1)
    
    main(sys.argv[1], sys.argv[2])