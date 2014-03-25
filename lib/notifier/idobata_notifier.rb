class TwentyNineHours
  class IdobataNotifier < Notifier
    def initialize(config)
      @url    = config["endpoint_url"]
      @client = HTTPClient.new
    end

    def notify(title, body, options = {})
      source = "<div><img src='#{options[:icon_url]}' width='24' height='24' />&nbsp;<span>#{title}</span></div><div>#{body}</div><div><a href='#{options[:link_url]}'>#{options[:link_url]}</a></div>"

      @client.post(@url, source: source, format: "html")
    end
  end
end
