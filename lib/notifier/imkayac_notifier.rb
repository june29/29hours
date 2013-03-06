require "digest/sha1"

class TwentyNineHours
  class ImkayacNotifier < Notifier
    def initialize(config)
      @username = config["username"]
      @password = config["password"]
      @sig      = config["sig"]
    end

    def notify(title, body, options = {})
      message = [title, body].join("\n")

      ImKayac.post(@username, message, {
        handler:  options[:link_url],
        password: @password,
        sig:      @sig ? Digest::SHA1.hexdigest(body + @sig) : nil
      })
    end
  end
end
