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

      imkayac = ImKayac.to(@username)
      imkayac.password(@password) if @password
      imkayac.sig(@sig)           if @password
      imkayac.handler(options[:link_url])
      imkayac.post(message)
    end
  end
end
