#
# Be sure to run `pod lib lint GTPDFReader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GTPDFKitten'
  s.version          = '0.1.1'
  s.summary          = 'A short description of GTPDFReader.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/gorillatech/PDFKitten'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'License.txt' }
  s.author           = { 'gorillatech' => 'guglielmo@gorillatech.io' }
  s.source           = { :git => 'https://github.com/gorillatech/PDFKitten.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PDFKitten/**/*.{m,h,mm}'
  s.resources =    'PDFKitten/**/*.{xib,lproj}'
  s.exclude_files  =  [
     'PDFKitten/PDFPage.*',
     'PDFKitten/PageView.*',
     'PDFKitten/PageViewController.*',
     'PDFKitten/RootViewController.*',
     'PDFKitten/PDFKittenAppDelegate.*'
  ]
  s.prefix_header_file = 'PDFKitten/PDFKitten-Prefix.pch'
  s.requires_arc = true


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end
