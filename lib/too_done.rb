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
     list = current_user.lists.find_by(name: options[:list])
          if list == nil
           puts "No list found."   
           exit
          end
          puts "Current List: #{list}"
          puts "which task should be changed?"
          task_id = STDIN.gets.chomp.to_i
          puts "Enter the new title:"
          new_title = STDIN.gets.chomp
          edit_task = Task.find(task_id)
          edit_task.text = new_title 
          edit_task.save
          task.each do |list|
          puts "ID: #{list.id}, Title: #{list.text}"
          end

          # display the tasks and prompt for which one to edit
          # or tasks.each do |t|
          #   puts "ID: #{t.id} | Task: {t.name} Due:"
          #end


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
      else 
        tasks = Task.where(list_id: list.id)
        puts "Please name the list to be marked done"
        task_completed = STDIN.gets.chomp.to_i
        task = Task.find(task_completed)
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
        tasks.each do |task|
          puts "ID: #{task.id}, Title: #{task.text}, Done?: #{task.completed}"
          if task.completed==false
          puts "task not done"
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
        exit
      end
        # BAIL if neither list or user option is provided
       unless options[:list] || options[:user]
         puts "You must provide an option."
         exit
       end
      if options[:list]
          list = current_user.lists.find_by(name: options[:list])
          #binding.pry
          list.destroy
          puts list.name + " has been DESTROYED!!"
        end
        if options[:user]
          user=User.find_by(name: options[:user])
          user.destroy
          puts user.name + "destroyed"
        end
          #if(list||user).destroy
      end
      #binding.pry
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
