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

  # make sure DOTENV is set, defaults to "default"
  ENV["DOTENV"] ||= "default"

  # load ENV variables from file specified by DOTENV
  # use .env with DOTENV=default
  filename = ENV["DOTENV"] == "default" ? ".env" : ".env.#{ENV['DOTENV']}"
  Dotenv.load! File.expand_path("../#{filename}", __FILE__)
rescue LoadError
  $stderr.puts "Please install dotenv plugin with \"vagrant plugin install dotenv\""
  exit
rescue Errno::ENOENT
  $stderr.puts "Please create #{filename} file, or use DOTENV=example for example configuration"
  exit
end

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here.

  # Check if required plugins are installed.
  required_plugins = %w{ vagrant-omnibus vagrant-bindfs dotenv }

  unless installed_plugins(required_plugins).empty?
    puts "Plugins have been installed, please rerun vagrant."
    exit
  end

  # load ENV variables
  load_env

  # Install latest version of Chef
  config.omnibus.chef_version = "12.5.1"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/ubuntu-14.04"

  # Enable provisioning with chef solo
  config.vm.provision :chef_solo do |chef|
    chef.json = { "dotenv" => ENV["DOTENV"], "application" => ENV["APPLICATION"] }
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
  config.vm.define ENV["DOTENV"] do |machine|
    # Override settings for specific providers
    machine.vm.provider :virtualbox do |vb, override|
      vb.name = "#{ENV["APPLICATION"]}.virtualbox"
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      unless Vagrant::Util::Platform.windows?
        # Disable default synced folder before bindfs tries to bind to it
        override.vm.synced_folder ".", "/var/www/#{ENV['APPLICATION']}", disabled: true
        override.vm.synced_folder ".", "/vagrant", id: "vagrant-root", nfs: true
        override.bindfs.bind_folder "/vagrant", "/var/www/#{ENV['APPLICATION']}",
                                    :owner => "900",
                                    :group => "900",
                                    :"create-as-user" => true,
                                    :perms => "u=rwx:g=rwx:o=rwx",
                                    :"create-with-perms" => "u=rwx:g=rwx:o=rwx",
                                    :"chown-ignore" => true,
                                    :"chgrp-ignore" => true,
                                    :"chmod-ignore" => true
      end
    end

    machine.vm.provider :vmware_fusion do |fusion|
      fusion.vmx["memsize"] = "2048"
      fusion.vmx["numvcpus"] = "2"
    end

    machine.vm.hostname = ENV.fetch('HOSTNAME')
    machine.vm.network :private_network, ip: ENV.fetch('PRIVATE_IP', nil)
    machine.vm.network :public_network
    machine.vm.synced_folder ".", "/var/www/#{ENV['APPLICATION']}", id: "vagrant-root"
  end
end
