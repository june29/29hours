class TwentyNineHours
  class TwitterLinker < Linker
    def build(tweet)
      "twitter://status?id=%d" % [tweet["id_str"]]
    end
  end
end
