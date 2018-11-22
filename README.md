# Spinone

[![Build Status](https://travis-ci.org/datacite/spinone.svg?branch=master)](https://travis-ci.org/datacite/spinone) [![Code Climate](https://codeclimate.com/github/datacite/spinone/badges/gpa.svg)](https://codeclimate.com/github/datacite/spinone) [![Test Coverage](https://codeclimate.com/github/datacite/spinone/badges/coverage.svg)](https://codeclimate.com/github/datacite/spinone/coverage)

The DataCite REST API that includes information from the Metadata Store (MDS) as well as other services, and provides this information via a common REST API using the [JSONAPI](http://jsonapi.org/) specification.

Examples:

```
https://api.datacite.org/works?query=cancer&page[size]=100
https://api.datacite.org/members?region=emea&year=2016
https://api.datacite.org/pages?tag=orcid

```

The full documentation can be found [here](https://support.datacite.org/docs/api).

## Installation

Using Docker.

```
docker run -p 8040:80 datacite/spinone
```

You can now point your browser to `http://localhost:8040` and use the application. For a more detailed configuration, including serving the application from the host for live editing, look at `docker-compose.yml` in the root folder.

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
