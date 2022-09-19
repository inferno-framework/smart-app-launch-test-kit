module SMARTAppLaunch
  module URLHelpers
    def make_url_absolute(base_url, endpoint)
      endpoint ? URI.join(base_url, endpoint).to_s : endpoint
    end
  end
end
