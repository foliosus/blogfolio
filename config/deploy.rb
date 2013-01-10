require 'new_relic/recipes'
require 'bundler/capistrano'

set :rvm_ruby_string, 'ree-1.8.7-2012.02@blogfolio'
set :rvm_type, :root
require 'rvm/capistrano'

set :application, 'blogfolio'
set :domain, 'foliosus.com'
set :user, 'deployer'

set :scm, 'git'
set :repository,  "git://github.com/foliosus/blogfolio.git"
set :branch, 'master'
# set :deploy_via, :remote_cache

set :use_sudo, false
set :deploy_to, "~/app"
set :group_writable, false
set :keep_releases, 3

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  after 'deploy:update', 'newrelic:notice_deployment'
  
  task :start, :roles => :app do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :restart, :roles => :app do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :symlink_database_yml, :roles => :app do
    run "ln -s #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"
    run "ln -s #{deploy_to}/shared/system/clients #{deploy_to}/current/public/clients"
  end
  after 'deploy:create_symlink', 'deploy:symlink_database_yml'
  
  task :restart_delayed_job, :roles => :app do
    run 'sudo restart delayed_job2'
  end
  after 'deploy:start', 'deploy:restart_delayed_job'
  after 'deploy:restart', 'deploy:restart_delayed_job'
end
