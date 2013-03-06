class TwentyNineHours
  class Notifier
    def initialize
    end

    def notify(message, options = {})
      puts message, options
    end
  end
end

require_relative "boxcar_notifier"
require_relative "imkayac_notifier"
