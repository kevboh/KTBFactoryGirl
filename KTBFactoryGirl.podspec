#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
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
  s.source           = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Classes'
  s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
