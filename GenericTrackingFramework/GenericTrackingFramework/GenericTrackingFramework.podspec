
Pod::Spec.new do |s|

  s.name             = 'GenericTrackingFramework'
  s.version          = '1.0.1'
  s.summary          = 'A swift view tracking framework'
  s.description      = 'View Tracking Framework written in Swift. Enables developers to : 1.Track % visibility of each view and its content 2.Track duration of on screen time 3.Create recommendations out of the accumulated data 4.Enable ads monetisation from the data'
  s.homepage         = 'https://github.com/Flipkart/GenericTrackingFramework'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kratijain-flipkart' => 'krati.jain@flipkart.com' }
  s.source           = { :git => 'https://github.com/Flipkart/GenericTrackingFramework.git', :tag => '1.0.1' }
  s.social_media_url = 'https://twitter.com/@kratijain'
  s.ios.deployment_target = '8.0'
  s.source_files = 'GenericTrackingFramework/**/*.{h,m}'

   s.frameworks = 'UIKit'
end