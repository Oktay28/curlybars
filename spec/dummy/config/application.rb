require File.expand_path('boot', __dir__)

require 'action_controller/railtie'

Bundler.require(*Rails.groups)
require "curlybars"

module Dummy
  class Application < Rails::Application
  end
end
