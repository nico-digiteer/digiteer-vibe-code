# Technical Specification for Jiro

This document describes the architecture for the Jiro ticketing system. The system is built on Rails 7, uses Hotwire for interactive UI, and Bootstrap 5 for styling. Below is the complete specification including database schema, models, routes, controllers, and service objects.

## 1. Database Schema

### Tables

#### Projects Table
```ruby
create_table :projects do |t|
  t.string :name, null: false
  t.string :key, null: false, index: { unique: true }
  t.text :description
  t.integer :status, null: false, default: 0 # enum status: { active: 0, archived: 1 }
  
  t.timestamps
end
```

#### Tickets Table
```ruby
create_table :tickets do |t|
  t.references :project, null: false, foreign_key: true
  t.string :title, null: false
  t.text :description
  t.integer :status, null: false, default: 0 # enum status: { open: 0, in_progress: 1, blocked: 2, resolved: 3 }
  t.integer :priority, null: false, default: 0 # enum priority: { low: 0, medium: 1, high: 2 }
  t.references :assigned_to, foreign_key: { to_table: :users }
  t.references :reporter, null: false, foreign_key: { to_table: :users }

  t.timestamps
end
```

#### Comments Table
```ruby
create_table :comments do |t|
  t.references :ticket, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.text :content, null: false

  t.timestamps
end
```

#### ActivityLogs Table
```ruby
create_table :activity_logs do |t|
  t.references :ticket, null: false, foreign_key: true
  t.string :action, null: false
  t.jsonb :details, default: {}

  t.timestamps
end
```

### Indexes
- For tickets:
  - `status`
  - `priority`
  - `assigned_to_id`
- For activity logs and comments, timestamps will be indexed for chronological queries.

### Migration File Examples

```ruby
class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :key, null: false, index: { unique: true }
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
```

## 2. Models

### Project Model
```ruby
class Project < ApplicationRecord
  has_many :tickets, dependent: :destroy
  
  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  enum status: { active: 0, archived: 1 }
end
```

### Ticket Model
```ruby
class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :reporter, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :comments, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  enum status: { open: 0, in_progress: 1, blocked: 2, resolved: 3 }
  enum priority: { low: 0, medium: 1, high: 2 }

  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_assignee, ->(user_id) { where(assigned_to_id: user_id) }
end
```

### Comment Model
```ruby
class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user
  
  validates :content, presence: true
end
```

### User Model
```ruby
class User < ApplicationRecord
  # Assume Devise or similar auth system in use
  has_many :tickets, foreign_key: 'reporter_id', dependent: :destroy
  has_many :assigned_tickets, class_name: 'Ticket', foreign_key: 'assigned_to_id', dependent: :destroy
  has_many :comments, dependent: :destroy

  enum role: { admin: 0, agent: 1, requester: 2 }
end
```

### ActivityLog Model
```ruby
class ActivityLog < ApplicationRecord
  belongs_to :ticket

  validates :action, presence: true
end
```

## 3. Routes

```ruby
Rails.application.routes.draw do
  resources :projects do
    resources :tickets, shallow: true do
      resources :comments, only: [:create]
      member do
        post 'transition'
        patch 'assign'
      end
    end
  end
  
  resources :users, only: [:index, :show] # For role management, etc.
end
```

## 4. Controller Structure

### ProjectsController
```ruby
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :archive]

  def index
    @projects = Project.all
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: 'Project successfully created.'
    else
      render :new
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project successfully updated.'
    else
      render :edit
    end
  end

  def archive
    @project.archived!
    redirect_to projects_path, notice: 'Project archived.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :key, :description, :status)
  end
end
```

### TicketsController
```ruby
class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :transition, :assign]
  before_action :set_project, only: [:create, :new]

  def index
    @tickets = Ticket.all
    filter_tickets
  end

  def create
    @ticket = @project.tickets.new(ticket_params)
    if @ticket.save
      redirect_to @ticket, notice: 'Ticket successfully created.'
    else
      render :new
    end
  end

  def update
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: 'Ticket successfully updated.'
    else
      render :edit
    end
  end

  def transition
    TransitionTicketService.new(@ticket, params[:status]).call
    redirect_to @ticket, notice: 'Ticket status updated.'
  end

  def assign
    AssignUserService.new(@ticket, params[:assigned_to_id]).call
    redirect_to @ticket, notice: 'Ticket assigned.'
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :assigned_to_id, :reporter_id)
  end

  def filter_tickets
    @tickets = @tickets.by_status(params[:status]) if params[:status].present?
    @tickets = @tickets.by_priority(params[:priority]) if params[:priority].present?
    @tickets = @tickets.by_assignee(params[:assigned_to_id]) if params[:assigned_to_id].present?
  end
end
```

### CommentsController
```ruby
class CommentsController < ApplicationController
  before_action :set_ticket

  def create
    @comment = @ticket.comments.new(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to ticket_path(@ticket), notice: 'Comment added.' }
      end
    else
      render :new
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
```

## 5. Service Objects

### TransitionTicketService
```ruby
class TransitionTicketService
  def initialize(ticket, new_status)
    @ticket = ticket
    @new_status = new_status
  end

  def call
    return unless Ticket.statuses.keys.include?(@new_status)

    @ticket.transaction do
      @ticket.update!(status: @new_status)
      @ticket.activity_logs.create!(action: 'status_changed', details: { new_status: @new_status })
    end
  end
end
```

### AssignUserService
```ruby
class AssignUserService
  def initialize(ticket, user_id)
    @ticket = ticket
    @user_id = user_id
  end

  def call
    user = User.find_by(id: @user_id)
    return unless user

    @ticket.transaction do
      @ticket.update!(assigned_to: user)
      @ticket.activity_logs.create!(action: 'assigned', details: { new_user: user.id })
    end
  end
end
```

### TicketFilterService (Example)
```ruby
class TicketFilterService
  def initialize(tickets, params)
    @tickets = tickets
    @params = params
  end

  def call
    filter_by_project if @params[:project].present?
    filter_by_status if @params[:status].present?
    filter_by_priority if @params[:priority].present?
    filter_by_assignee if @params[:assignee].present?
    @tickets
  end

  private

  def filter_by_project
    @tickets = @tickets.where(project_id: @params[:project])
  end

  def filter_by_status
    @tickets = @tickets.by_status(@params[:status])
  end

  def filter_by_priority
    @tickets = @tickets.by_priority(@params[:priority])
  end

  def filter_by_assignee
    @tickets = @tickets.by_assignee(@params[:assignee])
  end
end
```

## 6. Access Control and Permissions
Using Pundit or CanCanCan for role permissions:

```ruby
class ApplicationPolicy < Struct.new(:user, :record)
  def admin?
    user.admin?
  end

  def agent?
    user.agent?
  end

  def requester?
    user.requester?
  end
end

class ProjectPolicy < ApplicationPolicy
  def update?
    admin? || agent?
  end

  def show?
    admin? || agent? || (requester? && record.users.include?(user))
  end
end

class TicketPolicy < ApplicationPolicy
  def update?
    admin? || (agent? && record.project.users.include?(user))
  end

  def show?
    admin? || agent? || (requester? && record.reporter == user)
  end
end
```

## 7. Design Components
- All pages use Bootstrap 5 components:
  - Cards for project and ticket display.
  - Badges for status and roles.
  - Forms and modals for create/update actions.
- Slim templates for concise HTML.
- Turbo, Turbo Frames, and Stimulus for enhanced interaction.
- Stimulus controllers will handle actions like ticket status transitions, ticket filtering, and assignment management using Turbo Streams.

This architecture ensures clean separation of concerns, is scalable and maintainable, and aligns perfectly with Rails and Hotwire best practices.