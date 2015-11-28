# Spinone

[![Build Status](https://travis-ci.org/datacite/spinone.svg?branch=master)](https://travis-ci.org/datacite/spinone)
[![Code Climate](https://codeclimate.com/github/datacite/spinone/badges/gpa.svg)](https://codeclimate.com/github/datacite/spinone)
[![Test Coverage](https://codeclimate.com/github/datacite/spinone/badges/coverage.svg)](https://codeclimate.com/github/datacite/spinone/coverage)

## Local Installation

### Requirements

- Ruby (2.1 or higher)
- git
- Virtualbox: [https://www.virtualbox.org](https://www.virtualbox.org)
- Vagrant: [http://www.vagrantup.com](http://www.vagrantup.com)
- Vagrant omnibus plugin: `vagrant plugin install vagrant-omnibus`

### Installation

Using Virtualbox.

```
git clone https://github.com/datacite/spinone.git
cd spinone
cp .env.example .env
vagrant up --provider=virtualbox
```

If you don't see any errors from the last command, you now have a properly
configured Ubuntu virtual machine running `spinone`. You can point your
browser to `http://10.2.2.14`.

## Development

We use Rspec for unit and acceptance testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/spinone/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**spinone** is released under the [MIT License](https://github.com/datacite/spinone/blob/master/LICENSE).
