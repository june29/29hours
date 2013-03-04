class HttpLinker
  def initialize
  end

  def build(tweet)
    "http://twitter.com/%s/status/%s" % [tweet["user"]["screen_name"], tweet["id_str"]]
  end
end
