# -*- mode: ruby -*-
# vi: set ft=ruby :

def installed_plugins(required_plugins)
  required_plugins.reduce([]) do |missing, plugin|
    if Vagrant.has_plugin?(plugin)
      missing
    else
      puts "#{plugin} plugin is missing. Installing..."
      %x(set -x; vagrant plugin install #{plugin})
      missing << plugin
    end
  end
end

def load_env
  # requires dotenv plugin/gem
  require "dotenv"
  Dotenv.load! File.expand_path("../.env", __FILE__)
rescue LoadError
  $stderr.puts "Please install dotenv plugin with \"vagrant plugin install dotenv\""
  exit
rescue Errno::ENOENT
  $stderr.puts "Please create .env file, e.g. from .env.example"
  exit
end

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here.

  # Check if required plugins are installed.
  required_plugins = %w{ vagrant-omnibus dotenv }

  unless installed_plugins(required_plugins).empty?
    puts "Plugins have been installed, please rerun vagrant."
    exit
  end

  # load ENV variables
  load_env

  # Install latest version of Chef
  config.omnibus.chef_version = "12.5.1"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "phusion/ubuntu-14.04-amd64"

  # Enable provisioning with chef solo
  config.vm.provision :chef_solo do |chef|
    chef.json = { "application" => ENV["APPLICATION"] }
    chef.custom_config_path = "Vagrantfile.chef"
    chef.cookbooks_path = "vendor/cookbooks"
    dna = JSON.parse(File.read(File.expand_path("../node.json", __FILE__)))
    dna.delete("run_list").each do |recipe|
      chef.add_recipe(recipe)
    end
    chef.json.merge!(dna)
    chef.log_level = ENV["LOG_LEVEL"].to_sym
  end

  # allow multiple machines, specified by DOTENV
  config.vm.define "default" do |machine|
    # Override settings for specific providers
    machine.vm.provider :virtualbox do |vb, override|
      vb.name = "#{ENV["APPLICATION"]}"
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    machine.vm.provider :vmware_fusion do |fusion|
      fusion.vmx["memsize"] = "1024"
      fusion.vmx["numvcpus"] = "1"
    end

    machine.vm.hostname = ENV.fetch('HOSTNAME')
    machine.vm.network :private_network, ip: ENV.fetch('PRIVATE_IP', nil)
    machine.vm.network :public_network
    machine.vm.synced_folder ".", "/var/www/#{ENV['APPLICATION']}", id: "vagrant-root"
  end
end
