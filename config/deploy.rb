set :application, 'blogfolio'
set :domain, 'foliosus.com'
set :user, 'foliosu'

set :scm_user, 'foliosus'
set :repository, "svn+ssh://foliosu@foliosus.com/home/foliosu/svn/blogfolio/trunk/#{application}"

set :use_sudo, false
set :deploy_to, "~/app"
set :deploy_via, :checkout
set :group_writable, false
set :keep_releases, 3

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :restart, :roles => :app do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :after_symlink, :roles => :app do
    run "rm -f ~/public_html;ln -s #{deploy_to}/current/public ~/public_html"
    run "ln -s #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"
    run "ln -s #{deploy_to}/shared/system/clients #{deploy_to}/current/public/clients"
  end
end