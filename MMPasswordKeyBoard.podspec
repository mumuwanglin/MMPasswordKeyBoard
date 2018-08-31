#
# Be sure to run `pod lib lint MMPasswordKeyBoard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMPasswordKeyBoard'
  s.version          = '1.0.2'
  s.summary          = "简单好用的密码键盘"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description  = "简单好用的密码键盘，支持键盘混乱，加密"

  s.homepage         = 'https://github.com/mumuwanglin/MMPasswordKeyBoard.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '873621881@qq.com' => '873621881@qq.com' }
  s.source           = { :git => 'https://github.com/mumuwanglin/MMPasswordKeyBoard.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MMPasswordKeyBoard/Classes/**/*'
  
  s.resource_bundles = {
    'MMPasswordKeyBoard' => ['MMPasswordKeyBoard/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
