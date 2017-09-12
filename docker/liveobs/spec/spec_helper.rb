require "serverspec"
require "docker"

def image
  version = ENV['VERSION'] || 1
  "liveobs-rspec:#{version}"
end
