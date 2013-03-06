class TwentyNineHours
  class BoxcarNotifier < Notifier
    def initialize(config)
      @boxcar = BoxcarAPI::Provider.new(config["provider_key"], config["provider_secret"])
      @email  = config["email"]
    end

    def notify(title, body, options = {})
      @boxcar.notify(@email, body, {
        from_screen_name: title,
        icon_url:         options[:icon_url],
        source_url:       options[:link_url]
      })
    end
  end
end
