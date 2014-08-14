# Add all the ruby files in the directory /app/worker to LIBRARY_PATH
# that Ruby uses to load files that contain ruby code.
Dir[File.join(Rails.root, 'app', 'workers', '*.rb')].each { |file|
  require file }

# Load the redis.yml file and get the development section
config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
puts "Redis config is #{config}"

#Start up redis on the port and host from the redis.yml.
#Tell Resque about it.
Resque.redis = Redis.new(:host => config['host'], :port => config['port'])
