Pod::Spec.new do |s|
  s.name             = 'Kommander'
  s.version          = '0.9.3'
  s.summary          = 'A command pattern implementation written in Swift 4'

  s.homepage         = 'https://github.com/intelygenz/Kommander-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Alex Rupérez' => 'alejandro.ruperez@intelygenz.com', 'Juan Trías' => 'juan.trias@intelygenz.com', 'Roberto Estrada' => 'roberto.estrada@intelygenz.com' }
  s.source           = { :git => 'https://github.com/intelygenz/Kommander-iOS.git', :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/intelygenz"

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source_files     ="Source/*.{h,swift}"
end
