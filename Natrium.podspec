Pod::Spec.new do |s|
  s.name           = "Natrium"
  s.version        = "5.3.5"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.summary        = "An advanced pre-build swift script to alter your project per environment and build configuration."
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.preserve_paths = "bin/natrium", "bin/*.{sh,xcconfig,lock,log}"
  s.source_files   = "bin/*.{swift, h}"
  s.requires_arc   = true
  s.frameworks    = 'Foundation'

end
