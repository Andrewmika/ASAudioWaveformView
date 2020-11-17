# ASAudioWaveformView

[![Version](https://img.shields.io/cocoapods/v/ASAudioWaveformView.svg?style=flat)](https://cocoapods.org/pods/ASAudioWaveformView)
[![License](https://img.shields.io/cocoapods/l/ASAudioWaveformView.svg?style=flat)](https://cocoapods.org/pods/ASAudioWaveformView)
[![Platform](https://img.shields.io/cocoapods/p/ASAudioWaveformView.svg?style=flat)](https://cocoapods.org/pods/ASAudioWaveformView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![zoom](https://raw.githubusercontent.com/Andrewmika/MyPicBed/master/img/zoom1.gif)


## Requirements
swift 5.0+

## Installation

ASAudioWaveformView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ASAudioWaveformView'
```

## Usage
### there are two ways to create waveform view, waveform will adjust to fit the frame automatically

1. init with frame.
completion is Optional

    ```swift
    let wave = ASAudioWaveformView.create(frame: CGRect(x: 0, y: 40, width: 200, height: 100)) { (config) in
        let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
        config.audioURL(url).maxSamplesCount(500).fillColor(.systemTeal)
    } completion: { (empty) in
        print("-->draw Complete ,empty: \(empty)")
    }
    ```
2. if you use Autolayout or set the frame later.
    completion is Optional

    ```swift
    let wave = ASAudioWaveformView()
    wave.createWaveform { (config) in
            let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
            config.audioURL(url).positionType(.top).fillColor(.green)
    } completion: { (empty) in
        print("-->draw Complete ,empty: \(empty)")
    }
    ```

#### config waveform
```
    /// config waveform postion, the default is center
    public func positionType(_ type: ASAudioWaveformView.PositionType) -> ASAudioWaveformConfig

    /// config waveform content style, the default is polyline
    public func contentType(_ type: ASAudioWaveformView.ContentType) -> ASAudioWaveformConfig

    /// config waveform fill color, the default is yellow
    public func fillColor(_ color: UIColor) -> ASAudioWaveformConfig

    /// config waveform audio source
    public func audioURL(_ URL: URL?) -> ASAudioWaveformConfig

    /// config max samples count, the default is 1000
    public func maxSamplesCount(_ count: Int) -> ASAudioWaveformConfig
    
    /// Specifies a range of time that may limit the temporal portion of the receiver's asset from which media data will be read.The default value of timeRange is CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity).
    public func timeRange(_ range: CMTimeRange) -> ASAudioWaveformConfig
```

1. position type center, content type polyLine

	![center](https://raw.githubusercontent.com/Andrewmika/MyPicBed/master/img/center.png)

2. position type top, content type polyLine

	![top](https://raw.githubusercontent.com/Andrewmika/MyPicBed/master/img/top.png)
	
3. position type bottom, content type polyLine

	![bottom](https://raw.githubusercontent.com/Andrewmika/MyPicBed/master/img/bottom.png)
	
4. position type center, content type singleLine

	![single](https://raw.githubusercontent.com/Andrewmika/MyPicBed/master/img/single.png)
	
### reload with different audio URL
waveform will adjust to fit the frame automatically

```
/// Refresh waveform by audio url
public func refreshWaveform(with audioURL: URL?)
```


## Author

Andrew Shen, iandrew@126.com

## License

ASAudioWaveformView is available under the MIT license. See the LICENSE file for more info.
