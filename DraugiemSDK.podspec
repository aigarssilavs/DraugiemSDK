#
# Be sure to run `pod lib lint DraugiemSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DraugiemSDK"
  s.version          = "0.1.0"
  s.summary          = "Official Draugiem SDK for iOS."
  s.description      = "The Draugiem SDK for iOS enables you to use Draugiem authentication."
  s.homepage         = "https://github.com/Draugiem/draugiem-ios-sdk"
  s.license          = 'WTFPL'
  s.author           = { "Draugiem" => "api@draugiem.lv" }
  s.source           = { :git => "https://github.com/Draugiem/draugiem-ios-sdk.git", :tag => s.version.to_s }
  s.social_media_url = 'https://draugiem.lv/draugiem.lv'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DraugiemSDK' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/Public/**/*.h'
  s.frameworks = 'UIKit'
end
