class TwentyNineHours
  class PushoverNotifier < Notifier
    def initialize(config)
      Pushover.configure do |pushover_config|
        pushover_config.user   = config["user_token"]
        pushover_config.token  = config["app_token"]
        pushover_config.device = config["device"]
      end
      @sound    = config["sound"]
      @priority = config["priority"]

      if @priority == 2
        raise ':retry must have a value of at least 30(seconds)' if config["retry"] < 30
        raise ':expire must have a maximum value of at most 86400(seconds)' if config["expire"] > 86400
        @retry  = config["retry"]
        @expire = config["expire"]
      end
    end

    def notify(title, body, options = {})
      Pushover.notification(
        message:  body,
        title:    title,
        url:      options[:link_url],
        sound:    @sound,
        priority: @priority,
        retry:    @retry,
        expire:   @expire
      )
    end
  end
end
