Pod::Spec.new do |spec|
  spec.name = 'IBKUIComponents'
  spec.version = '1.0.0'
  spec.summary = 'Componentes UIKit reutilizables para IBKProducts.'
  spec.homepage = 'https://github.com/DannyPulache/IBKProducts'
  spec.license = { :type => 'MIT' }
  spec.author = { 'Danny Pulache' => 'danny.pulache1238@gmail.com' }
  spec.source = { :git => spec.homepage, :tag => spec.version.to_s }
  spec.ios.deployment_target = '15.0'
  spec.swift_version = '5.9'
  spec.source_files = 'Classes/**/*.swift'
  spec.frameworks = 'UIKit'
end
