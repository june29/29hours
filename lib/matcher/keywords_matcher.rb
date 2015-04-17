class TwentyNineHours
  class KeywordsMatcher < Matcher
    def initialize(keywords)
      @regexp = Regexp.union(keywords)
    end

    def match?(tweet)
      @regexp =~ tweet.text
    end
  end
end
