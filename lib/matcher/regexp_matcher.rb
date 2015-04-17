class TwentyNineHours
  class RegexpMatcher < Matcher
    def initialize(pattern)
      @regexp = Regexp.compile(pattern)
    end

    def match?(tweet)
      @regexp =~ tweet.text
    end
  end
end
