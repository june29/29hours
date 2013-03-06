class TwentyNineHours
  class HttpLinker < Linker
    def build(tweet)
      "http://twitter.com/%s/status/%s" % [tweet["user"]["screen_name"], tweet["id_str"]]
    end
  end
end
