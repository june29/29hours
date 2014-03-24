class TwentyNineHours
  class IdobataNotifier < Notifier
    def initialize(config)
      @url    = config["endpoint_url"]
      @client = HTTPClient.new
    end

    def notify(title, body, options = {})
      source = "<div style='margin-bottom: 5px;'><img src='#{options[:icon_url]}' width='24' height='24' style='margin-right: 4px;' />#{title}</div><div style='margin-bottom: 5px;'>#{body}</div><div><a href='#{options[:link_url]}'>#{options[:link_url]}</a></div>"

      @client.post(@url, source: source, format: "html")
    end
  end
end
