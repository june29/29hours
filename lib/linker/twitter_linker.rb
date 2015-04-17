class TwentyNineHours
  class TwitterLinker < Linker
    def build(tweet)
      "twitter://status?id=#{tweet.id}"
    end
  end
end
