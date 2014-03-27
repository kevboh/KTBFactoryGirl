Pod::Spec.new do |s|
  s.name             = "KTBFactoryGirl"
  s.version          = "0.0.1"
  s.summary          = "A partial port of ruby's factory_girl for Objective-C."
  # s.description      = <<-DESC
  #                      An optional longer description of KTBFactoryGirl

  #                      * Markdown format.
  #                      * Don't worry about the indent, we strip it!
  #                      DESC
  s.homepage              = "https://github.com/kevboh/KTBTaskQueue"
  s.license               = 'MIT'
  s.author                = { "Kevin Barrett" => "kevin@littlespindle.com" }
  s.social_media_url      = "https://twitter.com/kevboh"
  s.source           = { :git => "https://github.com/kevboh/KTBFactoryGirl.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Classes'

  s.platform = :ios
  s.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.8"

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
end
