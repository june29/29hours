class TwentyNineHours
  class HttpLinker < Linker
    def build(tweet)
      tweet.uri.to_s
    end
  end
end
