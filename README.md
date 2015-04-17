# ♰ 29hours ♰

[![Dependency Status](https://gemnasium.com/june29/29hours.png)](https://gemnasium.com/june29/29hours)

Notification specified Twitter application that is running 29 hours everyday.

### ♰ Features ♰

The 29hours works with pluggable Matcher, Notifier, and Linker.

- Matchers
  - KeywordsMatcher, RegexpMatcher, UsersMatcher
- Notifiers
  - BoxcarNotifier, ImkayacNotifier, PushoverNotifier, IdobataNotifier
- Linker
  - HttpLinker, TwitterLinker, TweetbotLinker

### ♰ Restarting dyno on Heroku ♰

You can restart dyno on Heroku with following commands.

```
$ heroku config:set HEROKU_API_TOKEN=xxx HEROKU_APP_NAME=yyy
$ bundle exec rake heroku:restart
```

If you want to restart periodically to refresh process, you can use [Heroku Scheduler](https://elements.heroku.com/addons/scheduler "Heroku Scheduler - Add-ons - Heroku Elements") and so on.
