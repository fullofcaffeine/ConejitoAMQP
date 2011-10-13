load 'deploy' if respond_to?(:namespace)

set :application, "conejito"
set :user, "root"
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:celoserpa/conejito.git"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/apps/#{application}"

role :app, "174.120.132.97"
role :web, "174.120.132.97"

namespace :deploy do
  task :start, :roles => [:app] do
    run "cd #{deploy_to}/current && bundle install"
    run "cd #{deploy_to}/current && nohup thin -R chat.rb start"
  end
end
