Gem::Specification.new do |s|
  s.name          = 'atpay_tokens'
  s.version       = '2.3.0'
  s.date          = '2013-11-28'
  s.summary       = "@Pay Token Generator"
  s.description   = "Client interface for the @Pay API, key generation for performance optimization"
  s.authors       = ["James Kassemi", "Glen Holcomb"]
  s.email         = 'dev@atpay.com'
  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.homepage      = "https://atpay.com"
  s.executables  = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.add_runtime_dependency 'ffi'
  s.add_runtime_dependency 'rbnacl'
  s.add_runtime_dependency 'trollop'
end
