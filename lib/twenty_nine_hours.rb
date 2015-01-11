# -*- coding: utf-8 -*-
require "logger"

require_relative "matcher/matcher"
require_relative "notifier/notifier"
require_relative "linker/linker"

LOGGER = Logger.new(STDOUT)
LOGGER.formatter = proc { |severity, datetime, progname, msg|
  "#{msg}\n"
}

STDOUT.sync = true

class TwentyNineHours
  def initialize(path)
    @path = path
    @settings = load_setitngs

    twitter = @settings["twitter"]
    @streamer = Streamer.new(twitter["my_screen_name"], {
      consumer_key:    twitter["consumer_key"],
      consumer_secret: twitter["consumer_secret"],
      access_key:      twitter["access_key"],
      access_secret:   twitter["access_secret"],
      }, settings_watcher)
    setup_streamer_attributes
  end

  def setup_streamer_attributes
    @streamer.matchers = @settings["matchers"].map { |key, value|
      TwentyNineHours.const_get("%sMatcher" % key.capitalize).new(value)
    }

    @streamer.notifiers = @settings["notifiers"].map { |key, value|
      TwentyNineHours.const_get("%sNotifier" % key.capitalize).new(value)
    }

    @streamer.linker = TwentyNineHours.const_get("%sLinker" % @settings["linker"].capitalize).new

    LOGGER.info status
  end

  def load_setitngs
    YAML.load(open(@path))
  end

  def watch
    @streamer.start
  end

  def status
    result = "TwentyNineHours:\n"

    result += "  Matchers:\n"
    @streamer.matchers.each do |matcher|
      result += "    %s\n" % matcher.class
    end

    result += "  Notifiers:\n"
    @streamer.notifiers.each do |notifier|
      result += "    %s\n" % notifier.class
    end

    result += "  Linker:\n"
    result += "    %s\n" % @streamer.linker.class

    result.gsub("TwentyNineHours::", "")
  end

  def settings_watcher
    proc {
      if settings_updated?
        LOGGER.info "Updating settings"
        @settings = load_setitngs
        setup_streamer_attributes
      end
    }
  end

  def settings_updated?
    @settings != load_setitngs
  end

  class Streamer
    PERIODIC_TASK_PERIOD = 60
    attr_accessor :matchers, :notifiers, :linker

    def initialize(me, oauth, *periodic_tasks)
      @me      = me
      @options = {
        host:  "userstream.twitter.com",
        path:  "/2/user.json",
        ssl:   true,
        oauth: oauth
      }
      @periodic_tasks = periodic_tasks
    end

    def start
      EventMachine::run {
        EventMachine::defer {
          @stream = Twitter::JSONStream.connect(@options)

          @stream.each_item { |item|
            data = Yajl::Parser.parse(item)
            handle(data)
          }

          @stream.on_error { |message|
            LOGGER.error "On error: #{message}"
            exit
          }
        }
        EventMachine::add_periodic_timer(PERIODIC_TASK_PERIOD) {
          @periodic_tasks.each { |task| task.call }
        }
      }
    end

    private
    def handle(data)
      if data["friends"]
        handle_friends(data)
        return
      end

      if data["text"]
        if data["retweeted_status"]
          handle_retweet(data)
        else
          handle_tweet(data)
        end
        return
      end

      if data["event"]
        handle_event(data)
      end
    end

    def handle_friends(data)
      LOGGER.info "You are following %d users." % data["friends"].size
    end

    def handle_tweet(data)
      text = data["text"]
      user = data["user"]
      name = user["screen_name"]

      LOGGER.info "@%s: %s" % [name, expand_url(text, data["entities"]["urls"])]

      @matchers.each do |matcher|
        if matcher.match?(data)
          @notifiers.each do |notifier|
            LOGGER.info "  Notify by %s" % notifier.class

            notifier.notify("✎ by @%s" % name, text,
              icon_url: user["profile_image_url"],
              link_url: @linker.build(data)
            )
          end
        end
      end
    end

    def handle_retweet(data)
      text = data["text"]
      user = data["user"]
      name = user["screen_name"]

      LOGGER.info "@%s (♺) %s" % [name, expand_url(text, data["entities"]["urls"])]

      if data["retweeted_status"]["user"]["screen_name"] == @me
        @notifiers.each do |notifier|
          LOGGER.info "  Notify by %s" % notifier.class

          notifier.notify("♺ by @%s" % name, text,
            icon_url: user["profile_image_url"],
            link_url: @linker.build(data["retweeted_status"])
          )
        end
      end
    end

    def handle_event(data)
      source = data["source"]
      target = data["target"]
      object = data["target_object"]

      case data["event"]
      when "favorite"
        LOGGER.info "@%s (☆) @%s: %s" % [source["screen_name"], object["user"]["screen_name"], object["text"]]

        unless source["screen_name"] == @me
          @notifiers.each do |notifier|
            LOGGER.info "  Notify by %s" % notifier.class

            notifier.notify("☆ by @%s" % source["screen_name"], object["text"],
              icon_url: source["profile_image_url"],
              link_url: @linker.build(object)
            )
          end
        end
      when "unfavorite"
      when "list_member_added"
      when "list_member_removed"
      when "follow"
      when "list_created"
      when "list_updated"
      when "list_destroyed"
      when "block"
      when "unblock"
      end
    end

    def expand_url(text, urls)
      return text if urls.empty?

      urls.inject(text) do |result, entry|
        url      = entry["url"]
        expanded = entry["expanded_url"]

        result.sub(url, expanded)
      end
    end
  end
end
