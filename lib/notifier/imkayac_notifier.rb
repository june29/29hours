require "digest/sha1"

class TwentyNineHours
  class ImkayacNotifier < Notifier
    def initialize(config)
      @username = config["username"]
      @password = config["password"]
      @sig      = config["sig"]
    end

    def notify(message, options = {})
      body = options[:from] + "\n" + message

      ImKayac.post(@username, body, {
        handler:  options[:link_url],
        password: @password,
        sig:      @sig ? Digest::SHA1.hexdigest(body + @sig) : nil
      })
    end
  end
end
