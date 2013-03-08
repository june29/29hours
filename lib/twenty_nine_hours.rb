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
  def initialize(settings)
    @matchers = settings["matchers"].map { |key, value|
      TwentyNineHours.const_get("%sMatcher" % key.capitalize).new(value)
    }

    @notifiers = settings["notifiers"].map { |key, value|
      TwentyNineHours.const_get("%sNotifier" % key.capitalize).new(value)
    }

    @linker = TwentyNineHours.const_get("%sLinker" % settings["linker"].capitalize).new

    LOGGER.info status

    twitter = settings["twitter"]

    @streamer = Streamer.new(twitter["my_screen_name"], {
      consumer_key:    twitter["consumer_key"],
      consumer_secret: twitter["consumer_secret"],
      access_key:      twitter["access_key"],
      access_secret:   twitter["access_secret"],
      }, @matchers, @notifiers, @linker)
  end

  def watch
    @streamer.start
  end

  def status
    result = "TwentyNineHours:\n"

    result += "  Matchers:\n"
    @matchers.each do |matcher|
      result += "    %s\n" % matcher.class
    end

    result += "  Notifiers:\n"
    @notifiers.each do |notifier|
      result += "    %s\n" % notifier.class
    end

    result += "  Linker:\n"
    result += "    %s\n" % @linker.class

    result.gsub("TwentyNineHours::", "")
  end

  class Streamer
    def initialize(me, oauth, matchers, notifiers, linker)
      @me      = me
      @options = {
        host:  "userstream.twitter.com",
        path:  "/2/user.json",
        ssl:   true,
        oauth: oauth
      }

      @matchers  = matchers
      @notifiers = notifiers
      @linker    = linker
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
