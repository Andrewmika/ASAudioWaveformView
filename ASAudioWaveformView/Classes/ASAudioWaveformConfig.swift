//
//  ASAudioWaveformConfig.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/11/16.
//

import Foundation
import CoreMedia

public class ASAudioWaveformConfig {
    var positionType: ASAudioWaveformView.PositionType = .center
    var contentType: ASAudioWaveformView.ContentType = .polyLine
    var fillColor: UIColor = .yellow
    var audioURL: URL?
    var maxSamplesCount: Int = 600
    var timeRange: CMTimeRange = CMTimeRangeMake(start: .zero, duration: .positiveInfinity)
    
    /// config waveform postion, the default is center
    @discardableResult
    public func positionType(_ type: ASAudioWaveformView.PositionType) -> ASAudioWaveformConfig {
        positionType = type
        return self
    }
    
    /// config waveform content style, the default is polyline
    @discardableResult
    public func contentType(_ type: ASAudioWaveformView.ContentType) -> ASAudioWaveformConfig {
        contentType = type
        return self
    }
    
    /// config waveform fill color, the default is yellow
    @discardableResult
    public func fillColor(_ color: UIColor) -> ASAudioWaveformConfig {
        fillColor = color
        return self
    }
    
    /// config waveform audio source
    @discardableResult
    public func audioURL(_ URL: URL?) -> ASAudioWaveformConfig {
        audioURL = URL
        return self
    }
    
    /// config max samples count, the default is 1000
    @discardableResult
    public func maxSamplesCount(_ count: Int) -> ASAudioWaveformConfig {
        maxSamplesCount = count
        return self
    }
    
    /// Specifies a range of time that may limit the temporal portion of the receiver's asset from which media data will be read.The default value of timeRange is CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity).
    @discardableResult
    public func timeRange(_ range: CMTimeRange) -> ASAudioWaveformConfig {
        timeRange = range
        return self
    }
}
