class TwentyNineHours
  class SlackNotifier < Notifier
    def initialize(config)
      @token   = config["token"]
      @channel = config["channel"]
      @client  = HTTPClient.new
    end

    def notify(title, body, options = {})
      source = "<div><img src='#{options[:icon_url]}' width='24' height='24' />&nbsp;<span>#{title}</span></div><div>#{body}</div><div><a href='#{options[:link_url]}'>#{options[:link_url]}</a></div>"

      @client.post("https://slack.com/api/chat.postMessage", {
        token:    @token,
        channel:  @channel,
        username: title,
        text:     [body, options[:link_url]].join("\n"),
        icon_url: options[:icon_url]
      })
    end
  end
end
