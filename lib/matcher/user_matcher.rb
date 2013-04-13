class TwentyNineHours
  class UserMatcher < Matcher
    def initialize(screen_name)
      @screen_name = screen_name
    end

    def match?(tweet)
      @screen_name == tweet["user"]["screen_name"]
    end
  end
end
