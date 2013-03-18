Gem::Specification.new do |s|
  s.name        = 'atpay'
  s.version     = '0.0.1'
  s.date        = '2013-03-08'
  s.summary     = "@Pay OAuth2.0 API Client"
  s.description = "Client interface for the @Pay API, key generation for performance optimization"
  s.authors     = ["James Kassemi"]
  s.email       = 'james@atpay.com'
  s.files       = `git ls-files`.split($/)
  s.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  s.homepage    = "https://atpay.com"
  s.add_dependency "rbnacl"
  s.add_runtime_dependency 'ffi'
end
