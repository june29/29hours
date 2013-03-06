require "yaml"
require "open-uri"
require "bundler"

if ARGV.include?("--production")
  Bundler.require
else
  Bundler.require(:default, :development)
end

require_relative "lib/twenty_nine_hours"

path = ENV["SETTINGS_FILE_PATH"] || File.join(__dir__, "settings.yml")

settings = YAML.load(open(path))

TwentyNineHours.new(settings).watch
