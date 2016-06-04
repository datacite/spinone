# Check for required ENV variables, can be set in .env file
# ENV_VARS is hash of required ENV variables
env_vars = %w{ DB_USERNAME HOSTNAME MODE LAGOTTO_URL LAGOTTO_TOKEN JWT_SECRET_KEY }
env_vars.each { |env| fail ArgumentError,  "ENV #{env} is not set" if ENV[env].blank? }
ENV_VARS = Hash[env_vars.map { |env| [env, ENV[env]] }]
