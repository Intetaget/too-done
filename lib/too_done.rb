#edit, needs to be entered
#show needs correction
#delete  needed, not in
##done  needs work
#LIST   needs work


require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/task"
require "too_done/list"

require "thor"
require "pry"

module TooDone

  #binding.pry

  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    
    def add(task)
      list = List.find_or_create_by(name: options[:list], user_id: current_user.id)
      task = Task.create(text: task, list_id: list.id) 
      puts "Added #{task.text} to list:#{list.name}"
        #Need new migration to add due date and name
        # #binding.pry
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."

    def edit  
     list = List.find_by(user_id: current_user.id, name: options[:list]) 
         if list == nil
           puts "No list found."                                                                     
         end 


      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      # allow the user to change the title, due date
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    
    def done
      list = List.find_by user_id: current_user.id, name: options[:list]
      if list == nil
        puts "Sorry. List not found."
      else display_list
            puts "Please name the list to be marked done"
      task_completed = STDIN.gets.chomp
      task = Task.find_by(name: task_completed)
      task.update(completed: true)
      puts "#{task_completed} marked as completed"
      end
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
        
    def show
      list = List.find_by user_id: current_user.id, name: options[:list]
      if list == nil
        puts "List not found: #{options[:list]}"
      else
        tasks = Task.where(list_id: list.id)
        #task = tasks.first
        # loop over the tasks and print them
        tasks.each do |task|
          puts "ID: #{task.id}, Title: #{task.text}"
        end
      end
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    
    def delete
      if options[:list] && options[:user]
        puts "You can delete a list *OR* a user. Not both."
      elsif
          list = current_user.lists.find_by(text: options[:list])
          list.destroy
          #f(list||user).destroy
      end

    end

    desc "switch USER", "Switch session to manage USER's todo lists."
      
      def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user
      Session.last.user
    end
  end
end

# binding.pry
TooDone::App.start(ARGV)
