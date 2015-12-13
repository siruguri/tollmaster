# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

require 'dotenv'
Dotenv.load

remote_server = ENV['RAILS_REMOTE_SERVER']
remote_port = ENV['RAILS_REMOTE_PORT']

server remote_server, user: "www-data", port: remote_port, roles: %w(web app db)
set :branch, 'master'
set :rails_env, :production

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
set :ssh_options, {
      keys: %w(/users/sameer/.ssh/digital_ocean_sameer),
      port: 220,
    }

set :deploy_to, "/var/www/#{fetch(:full_app_name)}"
