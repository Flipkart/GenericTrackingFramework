#
# Be sure to run `pod lib lint GenericTrackingFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GenericTrackingFramework'
  s.version          = '0.1.0'
  s.summary          = 'A Framework for tracking % visibility of each widget and its content'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Framework for tracking % visibility of each widget and its content
                       DESC

  s.homepage         = 'https://github.com/kratijain-flipkart/GenericTrackingFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kratijain-flipkart' => 'krati.jain@flipkart.com' }
  s.source           = { :git => 'https://github.com/kratijain-flipkart/GenericTrackingFramework.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GenericTrackingFramework/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GenericTrackingFramework' => ['GenericTrackingFramework/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
   s.dependency 'AsyncDisplayKit', '2.2'
end
