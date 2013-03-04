class BoxcarNotifier
  def initialize(config)
    @boxcar = BoxcarAPI::Provider.new(config["provider_key"], config["provider_secret"])
    @email  = config["email"]
  end

  def notify(message, options = {})
    @boxcar.notify(@email, message, options)
  end
end
