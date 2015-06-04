# It's good security practice to use a different port value for the SSH daemon than the default (22)
server "mydeploymentserver.net", user: "www-data", port: 220

set :branch, 'master'
set :rails_env, :development

set :ssh_options, {
      # This is where my SSH keys are
      keys: %w(/users/sameer/.ssh/digital_ocean_sameer),
      port: 220,
    }

set :deploy_to, "/var/www/railsapps/#{fetch(:full_app_name)}"

#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
