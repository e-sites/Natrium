Pod::Spec.new do |s|
  s.name           = "Natrium"
  s.version        = "1.0"
  s.platform       = :ios, "8.0"
  s.summary        = "An advanced pre-build ruby script to alter your project per environment and build configuration."
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.preserve_paths = "#{s.name}/*.{sh,rb,xcconfig}"
  s.source_files   = "#{s.name}/*.{h,swift}"
  s.requires_arc   = true
  s.frameworks    = 'Foundation'

end
