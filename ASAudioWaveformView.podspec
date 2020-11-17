#
# Be sure to run `pod lib lint ASAudioWaveformView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASAudioWaveformView'
  s.version          = '1.0.4'
  s.summary          = 'a simple and easy way to create audio waveform view'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
easy to create audio waveform view and it will adjust to fit the frame automatically!!
                       DESC

  s.homepage         = 'https://github.com/Andrewmika/ASAudioWaveformView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Shen' => 'iandrew@126.com' }
  s.source           = { :git => 'https://github.com/Andrewmika/ASAudioWaveformView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ASAudioWaveformView/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'ASAudioWaveformView' => ['ASAudioWaveformView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'CoreMedia'
  # s.dependency 'AFNetworking', '~> 2.3'
end
