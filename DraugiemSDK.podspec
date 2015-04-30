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
  s.description      = "The Draugiem SDK for iOS enables you to use Draugiem platform features, such as Draugiem authentication and payments."
  s.homepage         = "https://github.com/aigarssilavs/DraugiemSDK"
  s.license          = 'WTFPL'
  s.author           = { "Aigars Silavs" => "aigars.silavs@gmail.com" }
  s.source           = { :git => "https://github.com/aigarssilavs/DraugiemSDK.git", :tag => s.version.to_s }
  s.social_media_url = 'https://draugiem.lv/aigarss'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DraugiemSDK' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/Public/**/*.h'
  s.frameworks = 'UIKit'
end
