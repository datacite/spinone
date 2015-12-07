# load .env configuration file with ENV variables
# copy configuration file to shared folder
dotenv node["application"] do
  dotenv          node["dotenv"]
  action          :nothing
end.run_action(:load)

# install and configure dependencies
include_recipe "apt"
include_recipe "nodejs"

# add Phusion PPA for Nginx compiled with Passenger
apt_repository "phusion-passenger-#{node['lsb']['codename']}" do
  uri          "https://apt.dockerproject.org/repo"
  distribution node['lsb']['codename']
  components   ["main"]
  keyserver    "hkp://p80.pool.sks-keyservers.net:80"
  key          "58118E89F3A912897C070ADBF76221572C52609D"
  action       :add
  notifies     :run, "execute[apt-get update]", :immediately
end

# install nginx with passenger
%w{ nginx-full passenger }.each do |pkg|
  package pkg do
    options "-y --force-yes"
    action :install
  end
end

# nginx configuration
template 'nginx.conf' do
  path   "#{node['nginx']['dir']}/nginx.conf"
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :nothing
end

# create required files and folders, and deploy application
capistrano node["application"] do
  user            ENV['DEPLOY_USER']
  group           ENV['DEPLOY_GROUP']
  rails_env       ENV['RAILS_ENV']
  action          [:config, :bundle_install, :npm_install, :precompile_assets, :restart]
end
