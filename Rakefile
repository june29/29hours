require "platform-api"

namespace :heroku do
  desc "restarts all dynos to refresh process"
  task :restart do
    client = PlatformAPI.connect(ENV["HEROKU_API_TOKEN"])
    dyno = PlatformAPI::Dyno.new(client)
    dyno.restart_all(ENV["HEROKU_APP_NAME"])
  end
end
