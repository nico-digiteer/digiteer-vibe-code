import warnings
import os
from dotenv import load_dotenv

from engineering_team.crew import EngineeringTeam

warnings.filterwarnings("ignore", category=SyntaxWarning, module="pysbd")
load_dotenv()

# Create output directory if it doesn't exist
os.makedirs('output', exist_ok=True)

requirements = """
Build a simple e-commerce website with these features:

1. PRODUCTS
   - List products in grid (Bootstrap cards)
   - Show: image, name, price
   - Search and filter by category
   - Product detail page
   - Add to cart button

2. CART
   - Add/remove items
   - Update quantities
   - Show total
   - Mini cart in navbar (Bootstrap badge)

3. CHECKOUT
   - Simple form: name, email, address
   - Order confirmation page

4. ADMIN
   - Add/edit products (Bootstrap form)
   - View orders (Bootstrap table)

DESIGN:
- Bootstrap 5 (navbar, cards, buttons, forms, badges)
- Mobile responsive (Bootstrap grid)
- Clean and simple

TECH:
- Rails 7+ with Slim templates
- Stimulus JS
- Bootstrap 5 (no custom CSS)
- Turbo for dynamic updates
"""


def run():
    """
    Run the research crew.
    """
    FEATURE_NAME = "ecommerce_store"
    inputs = {'requirements': requirements, 'feature_name': FEATURE_NAME,}

    # Create and run the crew
    print("Loaded OPENAI_API_KEY:", os.getenv("OPENAI_API_KEY")[:10], "...") 
    result = EngineeringTeam().crew().kickoff(inputs=inputs)
    print("RESULTTTTTTT")
    print(result)

if __name__ == "__main__":
    run()