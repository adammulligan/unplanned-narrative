require 'capistrano/shared_file'

require 'rvm/capistrano'
set :rvm_ruby_string, '2.0.0'

require 'bundler/capistrano'

set :application, "unplanned_narrative"
set :repository,  "git@github.com:adammulligan/unplanned-narrative.git"

set :scm, :git

set :use_sudo, false

default_run_options[:pty] = true

set :user, "adam"
set :group, user
set :runner, user

set :host, "#{user}@koby.cyanoryx.com"
role :web, host
role :app, host

set :rack_env, :production

set :deploy_to, "/var/www/kobayashi.cyanoryx.com/#{application}"
set :unicorn_conf, "#{current_path}/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

set :local_shared_dirs, %w(tmp/pids tmp/sockets log/)
set :shared_files, %w(unicorn.rb)

namespace :deploy do
  task :setup_unicorn do
    require 'erb'

    template = File.read(File.join(File.dirname(__FILE__), "..", 'unicorn.rb.erb'))
    rendered_template = ERB.new(template).result(binding)

    put rendered_template, "#{shared_path}/unicorn.rb"
  end

  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
  end

  task :start do
    run "cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
  end

  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end

after "deploy:setup", "deploy:setup_unicorn"
