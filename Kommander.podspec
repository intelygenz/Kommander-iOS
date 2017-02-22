Pod::Spec.new do |s|
  s.name             = 'Kommander'
  s.version          = '0.2.2-objc'
  s.summary          = 'A command pattern implementation written in Swift 3'

  s.homepage         = 'https://gitlab.intelygenz.com/ios/kommander'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Rupérez' => 'alejandro.ruperez@intelygenz.com', 'Juan Trías' => 'juan.trias@intelygenz.com', 'Roberto Estrada' => 'roberto.estrada@intelygenz.com' }
  s.source           = { :git => 'https://gitlab.intelygenz.com/ios/kommander.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Kommander/*.swift'
end

