# -*- coding: utf-8 -*-
class TwentyNineHours
  class Boxcar2Notifier < Notifier
    def initialize(config)
      @boxcar2 = URI.parse('https://new.boxcar.io/api/notifications')
      @access_token = config["access_token"]
    end

    def notify(title, body, options = {:sound => 'bird-1', :source_name => nil})
      Net::HTTP.post_form(@boxcar2, {
        'user_credentials' => @access_token,
        'notification[title]'        => title,
        'notification[long_message]' => body,
        'notification[sound]'        => options[:sound],
        'notification[source_name]'  => options[:source_name],
        'notification[icon_url]'     => options[:icon_url],
        'notification[open_url]'     => options[:link_url]
      })
    end
  end
end
