## Action Mailer with Resque.

We are going to start off with the completed rails action mailer lesson. From [Rails EMail Demo](https://github.com/ga-wdi-boston/wdi_10_rails_demo_email) github repo. This is from the 'done' branch.

#### Install Redis and start it.

This will start Redis locally on port 6379.

```
brew install redis
redis-server /usr/local/etc/redis.conf
```

#### Install Resque.  

Add this to the Gemfile and bundle
```
gem "resque", "~> 2.0.0.pre.1", github: "resque/resque"
```

#### Create a rake task in lib/tasks/redis.rake.  

This will make the Rails environment, (models, ...), available within Resque classes. Typically Resque workers.

```
require "resque/tasks"

 # Make Rails models, etc., available to Resque workers.
task "resque:setup" => :environment

```

#### Create a Redis config file in config/redis.yml  

```
defaults: &defaults
  host: localhost
  port: 6379

development:
  <<: *defaults

staging:
  <<: *defaults

production:
  <<: *defaults

```

#### Create a Resque initializer in config/initializers/resque.rb

```
Dir[File.join(Rails.root, 'app', 'workers', '*.rb')].each { |file|
  require file }

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
puts "Redis config is #{config}"

Resque.redis = Redis.new(:host => config['host'], :port => config['port'])

```

#### Start up all the Resque workers.

We don't have any yet, but it doesn't blow up :-)

```
rake resque:work QUEUE='*'
```

#### Start Rails and Register User.


Start rails and go to the localhost:3000. Enter in a name and email.

#### Check that the Mailcatcher has seen the welcome Email.

A welcome email for the new users should show up in the mailcatcher web interface 

http://localhost:1080/

