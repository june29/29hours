class TwentyNineHours
  class Notifier
    def initialize
    end

    def notify(title, body, options = {})
      puts title, message, options
    end
  end
end

require_relative "boxcar_notifier"
require_relative "imkayac_notifier"
