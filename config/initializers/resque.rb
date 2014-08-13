Dir[File.join(Rails.root, 'app', 'workers', '*.rb')].each { |file|
  require file }

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
puts "Redis config is #{config}"

Resque.redis = Redis.new(:host => config['host'], :port => config['port'])