class TwentyNineHours
  class BoxcarNotifier < Notifier
    def initialize(config)
      @boxcar = BoxcarAPI::Provider.new(config["provider_key"], config["provider_secret"])
      @email  = config["email"]
    end

    def notify(message, options = {})
      @boxcar.notify(@email, message, {
          icon_url:         options[:icon_url],
          source_url:       options[:link_url],
          from_screen_name: options[:from]
        })
    end
  end
end
