class TwentyNineHours
  class TweetbotLinker < Linker
    def build(tweet)
      "tweetbot://%s/status/%s" % [tweet["user"]["screen_name"], tweet["id_str"]]
    end
  end
end
