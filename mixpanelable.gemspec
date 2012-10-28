Gem::Specification.new do |s|
  s.name        = 'mixpanelable'
  s.version     = '0.1.0'
  s.summary     = "Track events from your backend easily with Mixpanelable."
  s.author      = "Matt De Leon"
  s.email       = 'matt@developertown.com'
  s.files       = ["lib/mixpanelable.rb"]

  s.add_dependency 'resque'
end