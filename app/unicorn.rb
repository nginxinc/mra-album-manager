require 'dotenv/load'

# set path to app that will be used to configure unicorn,
# note the trailing slash in this example
@dir = "/usr/src/app/"

worker_processes 2
working_directory @dir

timeout 30

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
if ENV['NETWORK'] == 'fabric'
  listen "/tmp/sockets/unicorn.sock", :backlog => 64
else
  listen "8080", :backlog => 64
end

# Set process id path
pid "/var/run/unicorn.pid"

# Set log file paths
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"
