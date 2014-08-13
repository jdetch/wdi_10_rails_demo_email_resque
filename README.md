## Action Mailer with Resque.

## Objectives

* Show the various communication types and terminology.
* Use Resque to deliver welcome emails ansynchronously

## Communication Types and Terms.


### Asynchronous Communication

__Asynchronous messaging__ will send a message and return immediately.

_A message can be a call to a method or function_. Calling a method is actually _sending a message_ to a object. 

_Smalltalk and many OO purist use the _sending a message_ language instead of calling a method._

##### Postal Service 

A good example of an __asynchronous message__ is sending a letter though the US Mail or through "the post". 

We will not get an immediate reply or response to our letter. It takes some time to get delivered. And we may, or may not get a reply.

The __channel__ that we sending the message through is the US Postal Service. The __message container__ is the envelope and __message content__ is the text in the letter.

If no reply is expected it would be a __fire and forget__ type of message. Thinking that most junk mail sent is a __fire and forget__ type of message.

If we have a reply to our letter then the recipient used the return address as a __callback__. The __message container__, envelope, has a return address that can be used as a __callback__.

If the letter is sent to more than one recipient it would be __multicast__. For example a bulk advertisement would be __multicast__ to many potential customers and the message would mostly be a __fire and forget__ message.

If the sender was frozen in suspended animation after sending the letter then they would be in __blocking mode__. _Imagine one deposits their letter in a mailbox and is frozen until the mailman delivers a reply._

Of course, we can go on with our lives while we wait for a response to a letter. So we operate in __non-blocking mode__. Doing something after depositing the letter.

If we continually check our mailbox for a reply to our letter we are __polling__ the mailbox. 

If we're really obsessed we could be stopped from doing anything until we receive a reply. Continually __polling__ our mailbox and doing nothing else, a kind of __blocking__, until we get a response. A desperate state it is.

##### Some terminology:

* __Asynchronous messaging__ 
	Send a message and return immediately.  

* __Blocking mode__ - Waiting for a reply to a message or operation until a reply is received.

* __Non-blocking mode__ - Send a message and return immediately to the entity that sent the message. No waiting for a reply to a message.

* __Fire and Forget__ - Send a message that you don't expect a reply to. 

* __Multicast__ - Send a message to more than one receiver. 

* __Point to Point__ - Send a message to a specific receiver.

* __Callback__ - The operation to perform by the reciever after processing an incomijng message. _Many times it will be an operation involving the sender of the message. Perhaps telling the sender of the status of the operation requested in the sent message._

* __Channel__ - A container of messages. Typically this would be a queue that each message would be sent to. But, there are many types of Channels.  
	* Priority Queue - Each message has a priority that it will processed according to.
	* Topic Hierarchy - A tree where each node is a _topic_ and a subscriber can register to recieve all messages for a topic and the sub-topics of a topic node. 
	* Persistent Queue - Persist the contents until in case the queue crashes and needs to restart in a known state.

##### Asynchronous communication/messaging examples.

* Telegraph - __Non-blocking__ , __point to point__ messaging.  
	Telegram is sent from one office to another.
* Email - __Non-blocking__. Can be __point to point__ or __multi-cast__.
	Sending to one receipient is __point to point__. Sending to a mailing list or CC'ng many would be __multicast__.
* Ajax HTTP Requests - __Non-blocking__, __point to point__. Typically requires a __callback__.
* DOM Event Handling - DOM Events are put into a web browser's queue and pulled out and processed after the Javascript call stack is empty. These are __non-blocking__ messages/events that are processed by a __callback__.


### Synchronous Communication

This should be more familiar to us as we have been mostly using this throughout this course.

__Synchronous messaging__ will send a message and __wait__ for a reply. 

##### Synchronous communication/messaging examples.

* Tawking to another person. A conversation.  
	_Unless your exceedingly pedantic an insist that each party in the conversation take turns talking._
* A phone call.
* Skype.
* Invoking a function or method. __Passing a message to an object__.
* Calling a function that will read data from a file. 
	Reading data from a file will __block__ the main execution thread of a program while it:  
	* Spins up the Disk Drive.
	* Does a transalation from virtual memory to physical memory.
	* Cause a page fault.
	* Look for the drive track and sector that the contents of the file resides in.
	* Read the contents from the disk.
	* Return the data read.
* Making a HTTP Request to remote API. We will __block__ until the API returns a response. 
	 Typically, we will have a timeout, 30 seconds maybe, that we wait for a reply.
* Uploading a file.  
	For example, if one has to upload a large video file it can __block__ the process that should be serving HTTP Requests. Maybe, the video needs to converted to another format? This can be a very long running process that will block the requestor for a long time.
	 
	 

#### Background
We are going to move the task of sending an email through Rails from being a __synchronous__ task to a __asynchronous__ task.

Resque implements a __Publisher Subcriber__ design pattern. Resque uses Redis to define __queues__, or __channels__, that we __publish__ messages into. 
http://www.eaipatterns.com/toc.html
Excellent resource for messaging pattern: [Enterprise Integration Patterns](http://www.eaipatterns.com/toc.html)


Rails will __publish__ a message that will represent some operation, send email in this case, into a __queue__.

These send email messages will be pulled out of the __queue__ and processed by __worker__ processes that __subscribe__ to the __queue__ that Rails is __publishing__ into. 


## Demo

We are going to start off with the completed rails action mailer lesson. From [Rails EMail Demo](https://github.com/ga-wdi-boston/wdi_10_rails_demo_email) github repo. This is from the 'done' branch.


#### Add a Reque Worker 

##### Modify the app/controllers/users_controller.rb file.

This will replace a __synchronous call__ to send an email with a _asynchronous call__. Resque.enqueue will push a messages into a Resque, backed by Redis, queue. 

The controller is acting as a __publisher__.  

```
def create
 ...
 # UserMailer.signup_confirmation(@user).deliver
 Resque.enqueue(MailWorker, @user.id)
 ... 
end
```


##### Create a file app/workers/mail_worker.rb (Setup a Worker/Subscriber)

This will create a Plain Old Ruby Object (PORO) that will be a Resque Worker.

A Worker subscribes to a queue pulling messages off that queue and processing them. In this case we will be pulling messages that direct the Workers to mail signup confirmations.

We MUST set a queue that the messages will be published into and subscribers/workers will pull off of.

The worker/s are __subscribers__. 

```
class MailWorker

  @queue = :mailer_queue

  def self.perform(user_id)
    @user = User.find(user_id)
    # Send sign up email
    UserMailer.signup_confirmation(@user).deliver
  end
end

```

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

## Lab

Implement the above using alternate background processing libraries such as, Delayed Job and Sidekiq. See Railscasts for these libraries and [Comparing Background Libraries](http://www.sitepoint.com/comparing-background-processing-libraries-resque/)

If you're feeling like a challenge send emails asynchronously with [ZeroMQ](http://www.sitepoint.com/zeromq-ruby/). 

OR if sending email doesn't work with ZeroMQ try executing a long running task with ZeroMQ. For example a large-ish fibonacci calculation as shown in [this article](http://www.sitepoint.com/zeromq-ruby/).