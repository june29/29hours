class KeywordsMatcher
  def initialize(keywords)
    @regexp = Regexp.compile(keywords.join("|"))
  end

  def match?(tweet)
    @regexp =~ tweet["text"]
  end
end
