//
//  ASAudioWaveformDataFactory.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/17.
//

import Foundation
import CoreMedia

typealias WaveSize = (width: Int, height: CGFloat)

struct ASAudioWaveformDataFactory {
    
    static func loadAudioWaveformData(from audioURL: URL, formateSize: WaveSize, timeRange: CMTimeRange, completion: @escaping ([Float]?, Data?) -> Void) {
        ASAudioDataReader.loadAudioData(from: audioURL, timeRange: timeRange) { (audioData) in
            if let data = audioData {
                let filteredPoints = ASAudioWaveformDataFilter.filtered(samples: data, for: formateSize)
                DispatchQueue.main.async {
                    completion(filteredPoints, data)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
        }
    }
}

