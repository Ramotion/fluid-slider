Pod::Spec.new do |s|
  s.name         = 'fluid-slider'
  s.version      = '1.2.0'
  s.summary      = 'A slider widget with a popup bubble displaying the precise value selected.'
  s.homepage     = 'https://github.com/Ramotion/fluid-slider'
  s.license      = 'MIT'
  s.authors = { 'Juri Vasylenko' => 'juri.v@ramotion.com' }
  s.ios.deployment_target = '12.0'
  s.source       = { :git => 'https://github.com/wedalo/fluid-slider', :tag => s.version.to_s }
  s.source_files  = 'Sources/*.swift'
  s.dependency 'pop'
end
