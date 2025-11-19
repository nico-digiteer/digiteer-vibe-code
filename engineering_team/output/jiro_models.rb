### Project Model - app/models/project.rb
```ruby
class Project < ApplicationRecord
  has_many :tickets, dependent: :destroy

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  enum status: { active: 0, archived: 1 }
  
  # Scopes
  scope :active, -> { where(status: :active) }
  scope :archived, -> { where(status: :archived) }

  # Methods for transitioning states or other business logic can be added here
end
```

### Ticket Model - app/models/ticket.rb
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

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_assignee, ->(user_id) { where(assigned_to_id: user_id) }
  scope :by_project, ->(project_id) { where(project_id: project_id) }
  
  # Methods for transitioning states or other business logic can be added here

  def transition_to!(new_status)
    if Ticket.statuses.keys.include?(new_status)
      with_transaction_returning_status do
        update!(status: new_status)
        activity_logs.create!(action: 'status_changed', details: { new_status: new_status })
      end
    end
  end

  def assign_to!(user)
    if user
      with_transaction_returning_status do
        update!(assigned_to: user)
        activity_logs.create!(action: 'assigned', details: { new_assignee_id: user.id })
      end
    end
  end
end
```

### Comment Model - app/models/comment.rb
```ruby
class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :content, presence: true

  # Scopes
  default_scope { order(created_at: :asc) }
end
```

### User Model - app/models/user.rb
```ruby
class User < ApplicationRecord
  # Assume Devise or similar auth system is in use
  has_many :tickets_as_reporter, class_name: 'Ticket', foreign_key: 'reporter_id', dependent: :destroy
  has_many :assigned_tickets, class_name: 'Ticket', foreign_key: 'assigned_to_id', dependent: :destroy
  has_many :comments, dependent: :destroy

  enum role: { admin: 0, agent: 1, requester: 2 }

  # Scope and methods for user-specific logic
end
```

### ActivityLog Model - app/models/activity_log.rb
```ruby
class ActivityLog < ApplicationRecord
  belongs_to :ticket

  validates :action, presence: true
end
```

These model files are designed to be lightweight, efficient, and aligned with Rails best practices. They incorporate enums for workflow management, contain necessary validations, define associations, and are prepared with scopes for easy filtering. The heavier business logic is reserved for service objects, ensuring models remain clean and focused on entity-state management.