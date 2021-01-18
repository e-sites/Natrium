Pod::Spec.new do |s|
  s.name           = "Natrium"
  s.version        = `sh get_version.sh`
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.summary        = "An advanced pre-build swift script to alter your project per environment and build configuration."
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.preserve_paths = [ "natrium" ]
  s.public_header_files = [ "Natrium/Sources/Natrium.h" ]
  s.source_files   = [ "Natrium/Sources/Natrium.h", "Natrium/Sources/Natrium.swift" ]
  s.requires_arc   = true
  s.frameworks    = 'Foundation'
  s.swift_versions = [ '4.2', '5.0', '5.3' ]
  s.prepare_command = <<-PREPARE_COMMAND_END
    cp -f ./Natrium/Sources/Natrium.swift ./Natrium/Natrium.swift
    chmod 7777 ./Natrium/Natrium.swift
  PREPARE_COMMAND_END
end
