# config valid only for current version of Capistrano
lock '3.4.0'

app_name = 'tollmaster'
set :application, app_name
set :full_app_name, app_name
set :repo_url, "https://www.github.com/siruguri/#{app_name}.git"
set :repository, "git@github.com:siruguri/#{app_name}.git"

set :bundle_without, [:test]

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/railsapps/my_app_name - this will be overridden in the
# Environment specific deploy config files 
set :deploy_to, "/var/www/#{app_name}"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, false

# Sidekiq
set :sidekiq_options_per_process, ["--queue sms_messages --queue stripe_interactions --queue mailers --queue invoices"]
set :sidekiq_monit_default_hooks, false

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('.env', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3
