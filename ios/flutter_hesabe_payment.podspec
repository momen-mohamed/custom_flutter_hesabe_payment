#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_hesabe_payment'
  s.version          = '2.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://wedoweb_android@bitbucket.org/wedoweb_android/hesabepayment-plugin.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wedowebapps PVT LTD.' => 'jeetb.wedowebapps@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '10.0'

  s.dependency 'CryptoSwift', '1.0'
  s.dependency 'Alamofire'

end

