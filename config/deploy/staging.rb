# It's good security practice to use a different port value for the SSH daemon than the default (22)

require 'dotenv'
Dotenv.load

remote_server = ENV['RAILS_REMOTE_DEPLOYMENT_SERVER']
remote_port = ENV['RAILS_REMOTE_PORT']

server remote_server, user: "www-data", port: remote_port, roles: %w(web app db)

set :deploy_to, "/var/www/railsapps/#{fetch(:full_app_name)}"
set :branch, 'working'
set :rails_env, :production

set :ssh_options, {
      # This is where my SSH keys are
      keys: %w(/users/sameer/.ssh/digital_ocean_sameer),
      port: 220,
    }
