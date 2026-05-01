Pod::Spec.new do |s|
  s.name             = 'SwiftTryCatch'
  s.version          = '1.0.0'
  s.summary          = 'Vendored SwiftTryCatch with NS_SWIFT_NAME for Virgil.'
  s.description      = <<-DESC
  Local vendored copy of williamFalcon/SwiftTryCatch (MIT) with an
  NS_SWIFT_NAME annotation so that flutter_dynamic_icon_plus can call
  +try:catch:finally: from Swift. The CocoaPods trunk podspec points
  to github.com/cfr/SwiftTryCatch which has been deleted.
                       DESC
  s.homepage         = 'https://github.com/williamFalcon/SwiftTryCatch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'William Falcon' => 'waf2107@columbia.edu' }
  s.source           = { :path => '.' }
  s.source_files     = '*.{h,m}'
  s.public_header_files = '*.h'
  s.platform         = :ios, '11.0'
  s.requires_arc     = true
end
