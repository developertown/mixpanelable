Gem::Specification.new do |s|
  s.name        = 'mixpanelable'
  s.version     = '0.2.1'
  s.summary     = "Track events from your Rails backend easily with Mixpanelable."
  s.author      = "Matt De Leon"
  s.email       = 'smidwap@gmail.com'
  s.files       = Dir["lib/**/*"]

  s.add_dependency 'resque'
  s.add_dependency 'rails'
  s.add_development_dependency 'rspec'
end