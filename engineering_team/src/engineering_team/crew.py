from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task

@CrewBase
class EngineeringTeam():
    """E-commerce Rails Development Team"""

    agents_config = 'config/agents.yaml'
    tasks_config = 'config/tasks.yaml'

    @agent
    def rails_architect(self) -> Agent:
        return Agent(
            config=self.agents_config['rails_architect'],
            verbose=True,
        )
    
    @agent
    def frontend_developer(self) -> Agent:
        return Agent(
            config=self.agents_config['frontend_developer'],
            verbose=True,
        )
    
    @agent
    def integration_engineer(self) -> Agent:
        return Agent(
            config=self.agents_config['integration_engineer'],
            verbose=True,
        )
    
    @task
    def architecture_task(self) -> Task:
        return Task(
            config=self.tasks_config['architecture_task']
        )

    @task
    def frontend_task(self) -> Task:
        return Task(
            config=self.tasks_config['frontend_task'],
        )

    @task
    def integration_task(self) -> Task:
        return Task(
            config=self.tasks_config['integration_task'],
        )

    @task
    def migration_task(self) -> Task:
        return Task(
            config=self.tasks_config['migration_task'],
        )

    @task
    def model_task(self) -> Task:
        return Task(
            config=self.tasks_config['model_task'],
        )

    @crew
    def crew(self) -> Crew:
        """Creates the e-commerce development crew"""
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True,
        )