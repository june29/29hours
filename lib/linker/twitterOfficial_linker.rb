class TwentyNineHours
  class Twitter_officialLinker < Linker
    def build(tweet)
      "twitter://status?id=%d" % [tweet["id_str"]]
    end
  end
end
