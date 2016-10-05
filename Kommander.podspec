#
# Be sure to run `pod lib lint Net.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Kommander'
  s.version          = '0.1.0'
  s.summary          = 'A command pattern implementation written in Swift 3'

  s.homepage         = 'https://gitlab.com/IGZArch/Kommander'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Juan Trías' => 'juan.trias@intelygenz.com' }
  s.source           = { :git => 'https://gitlab.com/IGZArch/Kommander.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Kommander/Classes/**/*'
end

