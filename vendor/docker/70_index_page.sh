#!/bin/sh
/sbin/setuser app cd vendor/middleman & bundle exec middleman build -e ${RAILS_ENV}
