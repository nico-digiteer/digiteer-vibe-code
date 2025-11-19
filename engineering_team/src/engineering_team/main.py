import warnings
import os
from dotenv import load_dotenv

from engineering_team.crew import EngineeringTeam

warnings.filterwarnings("ignore", category=SyntaxWarning, module="pysbd")
load_dotenv()

# Create output directory if it doesn't exist
os.makedirs('output', exist_ok=True)

requirements = """
Build a complete ticketing system with these required features:

1. PROJECTS
   - Create, view, update, and archive projects
   - Fields: name, key, description, status (active, archived)
   - List page showing all projects
   - Project detail page showing:
     - Project info
     - List of tickets for that project (with basic filtering by status and priority)

2. TICKETS
   - Create, view, update, and delete tickets
   - Every ticket must belong to a project
   - Fields: project, title, description, status (enum), priority (enum), assigned_to, reporter
   - Status workflow: open, in_progress, blocked, resolved
   - Global ticket list page with filtering by:
     - project
     - status
     - priority
     - assignee
   - Ticket detail page with full ticket information

3. COMMENTS
   - Add comments to a ticket
   - Display comments in chronological order
   - Comment form uses Turbo Frames (no full page reload)

4. ASSIGNMENT
   - Assign a ticket to a user
   - Change assignee from the ticket detail page
   - Display assignee using a Bootstrap badge

5. ACTIVITY LOGS
   - Automatically log changes to:
     - status
     - priority
     - assignee
   - Show activity feed on the ticket detail page

6. USER ROLES
   - Roles: admin, agent, requester
   - Admin: full access to all projects and tickets
   - Agent: manage tickets in all projects
   - Requester: create tickets and view only their own tickets
   - Access control must respect these roles

7. DESIGN
   - Use Bootstrap 5 components only:
     - cards, badges, buttons, tables, forms, alerts, navbars
   - Responsive layout using Bootstrap grid
   - Slim templates only (no ERB)
   - Use Turbo Frames/Streams for dynamic updates
   - Use Stimulus for interactivity (status change, filtering, assignment UI, simple modals)

8. TECH REQUIREMENTS
   - Rails 7+ with Slim templates
   - Stimulus controllers for UI interactions
   - Bootstrap 5 (no custom CSS)
   - Turbo for dynamic updates
   - Use Rails enums for ticket status and priority
"""

def run():
    """
    Run the research crew.
    """
    FEATURE_NAME = "jiro"
    inputs = {'requirements': requirements, 'feature_name': FEATURE_NAME,}

    # Create and run the crew
    print("Loaded OPENAI_API_KEY:", os.getenv("OPENAI_API_KEY")[:10], "...") 
    result = EngineeringTeam().crew().kickoff(inputs=inputs)
    print("RESULTTTTTTT")
    print(result)

if __name__ == "__main__":
    run()