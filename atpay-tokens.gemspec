Gem::Specification.new do |s|
  s.name        = 'atpay-tokens'
  s.version     = '0.0.5'
  s.date        = '2013-07-25'
  s.summary     = "@Pay Token Generator"
  s.description = "Client interface for the @Pay API, key generation for performance optimization"
  s.authors     = ["James Kassemi", "Glen Holcomb"]
  s.email       = 'james@atpay.com'
  s.files       = `git ls-files`.split($/)
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    = "https://atpay.com"
  s.add_dependency "rbnacl"
  s.add_runtime_dependency 'ffi'
end
