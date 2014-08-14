require "resque/tasks"

# Make Rails models, etc., available to Resque workers.
task "resque:setup" => :environment
