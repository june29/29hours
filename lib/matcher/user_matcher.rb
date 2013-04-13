class TwentyNineHours
  class UserMatcher < Matcher
    def initialize(screen_names)
      @screen_names = screen_names
    end

    def match?(tweet)
      @screen_names.include?(tweet["user"]["screen_name"])
    end
  end
end
