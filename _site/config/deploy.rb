require 'mt-capistrano'

set :site,         "0000"
set :application,  "onawednesday"
set :webpath,      "onawednesday.com"
set :domain,       "onawednesday.com"
set :user,         "serveradmin%primarydomain.com"
set :password,     "d9d14d88"

ssh_options[:username] = 'dave%iamdavedawson.com'

set :repository, "svn+ssh://#{user}@#{domain}/home/#{site}/data/svn/#{application}/trunk"
set :deploy_to,  "/home/#{site}/containers/rails/#{application}"

set :checkout, "export"

role :web, "#{domain}"
role :app, "#{domain}"
role :db,  "#{domain}", :primary => true

task :after_update_code, :roles => :app do
  put(File.read('config/database.yml'), "#{release_path}/config/database.yml", :mode => 0444)
end

task :restart, :roles => :app do
  run "mtr restart #{application} -u #{user} -p #{password}"
  run "mtr generate_htaccess #{application} -u #{user} -p #{password}"
  migrate
end