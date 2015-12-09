def whyrun_supported?
  true
end

use_inline_resources

def load_current_resource
  @current_resource = Chef::Resource::Capistrano.new(new_resource.name)
end

action :deploy do
end

action :config do
  # create folders
  %W{ #{new_resource.name} #{new_resource.name}/frontend #{new_resource.name}/vendor #{new_resource.name}/log #{new_resource.name}/tmp #{new_resource.name}/tmp/pids }.each do |dir|
    directory "/var/www/#{dir}" do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      recursive true
    end
  end
end

action :bundle_install do
  run_context.include_recipe 'ruby'

  if ::File.exist?("/var/www/#{new_resource.name}/Gemfile")
    # make sure we can use the bundle command
    execute "bundle install" do
      user new_resource.user
      cwd "/var/www/#{new_resource.name}"
      if new_resource.rails_env == "development"
        command "bundle config --delete without --no-deployment && bundle install --path vendor/bundle"
      else
        command "bundle install --path vendor/bundle --deployment --without development test"
      end
    end
  end
end

action :npm_install do
  run_context.include_recipe 'nodejs'

  if ::File.exist?("/var/www/#{new_resource.name}/frontend/package.json")
    # create directory for npm packages
    directory "/var/www/#{new_resource.name}/frontend/node_modules" do
      owner new_resource.user
      group new_resource.group
      mode '0755'
      action :create
    end

    # install npm packages, using information in package.json
    # we need to set $HOME because of a Chef bug: https://tickets.opscode.com/browse/CHEF-2517
    execute "npm install" do
      user new_resource.user
      cwd "/var/www/#{new_resource.name}/frontend"
      environment ({ 'HOME' => ::Dir.home(new_resource.user), 'USER' => new_resource.user })
      action :run
    end
  end
end

action :consul_install do
  # install consul
  run_context.include_recipe 'consul'
end

action :precompile_assets do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  if ::File.exist?("/var/www/#{new_resource.name}/Gemfile")
    # make sure we can use the bundle command

    execute "bundle exec rake assets:precompile" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd "/var/www/#{new_resource.name}"
      not_if { new_resource.rails_env == "development" }
    end
  end
end

action :ember_build do
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'ruby'

  # provide Rakefile if it doesn't exist, e.g. during testing
  cookbook_file "Rakefile" do
    path "/var/www/#{new_resource.name}/Rakefile"
    owner new_resource.user
    group new_resource.group
    cookbook "capistrano"
    action :create_if_missing
  end

  execute "bundle exec rake ember:build" do
    user new_resource.user
    environment 'RAILS_ENV' => new_resource.rails_env
    cwd "/var/www/#{new_resource.name}"
  end
end

action :migrate do
  run_context.include_recipe 'ruby'

  if ::File.exist?("/var/www/#{new_resource.name}/config/database.yml")
    # run database migrations
    execute "bundle exec rake db:migrate" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd "/var/www/#{new_resource.name}"
    end

    # load/reload seed data
    execute "bundle exec rake db:seed" do
      user new_resource.user
      environment 'RAILS_ENV' => new_resource.rails_env
      cwd "/var/www/#{new_resource.name}"
    end
  end
end

action :whenever do
  execute "whenever" do
    cwd  "/var/www/#{new_resource.name}"
    command "whenever --update-crontab -i #{new_resource.name}"
  end
end

action :restart do
  execute "restart" do
    cwd  "/var/www/#{new_resource.name}"
    command "mkdir -p tmp && touch tmp/restart.txt"
  end
end
