class TwentyNineHours
  class TweetbotLinker < Linker
    def build(tweet)
      "tweetbot://#{tweet.user.screen_name}/status/#{tweet.id}"
    end
  end
end
