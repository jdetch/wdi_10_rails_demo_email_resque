## Action Mailer with Resque.

We are going to start off with the completed rails action mailer lesson. From [Rails EMail Demo](https://github.com/ga-wdi-boston/wdi_10_rails_demo_email) github repo. This is from the 'done' branch.

#### Install Redis and start it.

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

#### Start up all the Resque workers.

We don't have any yet, but it doesn't blow up :-)

```
rake resque:work QUEUE='*'
```

