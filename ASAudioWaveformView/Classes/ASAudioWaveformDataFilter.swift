//
//  ASAudioWaveformDataFilter.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/17.
//

import Foundation

struct ASAudioWaveformDataFilter {
    static func filtered(samples data: Data, for size: WaveSize) -> [Float]? {
        guard size.width > 1 else {  return nil }
        var filteredSamples = [Float]()
        let samplesCount = data.count / MemoryLayout<Int16>.size
        let binSize = samplesCount / size.width
        let bytes = data.copyBytes()
        var maxSample: Int16 = 0
        for i in stride(from: 0, to: samplesCount - 1, by: binSize) {
            let minSize = min(binSize, samplesCount - i)
            let maxValue = bytes[i..<(i+minSize)].max() ?? 0
            filteredSamples.append(Float(maxValue))
            maxSample = max(maxSample, maxValue)
        }
        if maxSample != 0 {
            let scaleFactor = (size.height / 2) / CGFloat(maxSample)
            filteredSamples = filteredSamples.map { $0 * Float(scaleFactor) }
        }
        else {
            return nil;
        }
        
        
        return filteredSamples
    }
}

extension Data {
    func copyBytes() -> [Int16] {
        return withUnsafeBytes { Array($0.bindMemory(to: Int16.self))}
    }
}
