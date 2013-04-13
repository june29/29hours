class TwentyNineHours
  class Matcher
    def initialize
    end

    def match?(tweet)
      false
    end
  end
end

require_relative "keywords_matcher"
require_relative "regexp_matcher"
require_relative "users_matcher"
