//
//  ASAudioDataReader.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/17.
//

import Foundation
import AVFoundation

struct ASAudioDataReader {
    
    static func loadAudioData(from audioURL: URL, timeRange: CMTimeRange, completion: @escaping (Data?) -> Void) {
        let trackKey = "tracks"
        let asset = AVAsset(url: audioURL)
        asset.loadValuesAsynchronously(forKeys: [trackKey]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: trackKey, error: &error)
            var waveData: Data?
            if status == .loaded {
                waveData = loadAudioData(from: asset, timeRange: timeRange)
            }
            completion(waveData)
        }
    }
    
    private static func loadAudioData(from asset: AVAsset, timeRange: CMTimeRange) -> Data? {
        do {
            let assetReader = try AVAssetReader.init(asset: asset)
            assetReader.timeRange = timeRange
            guard let track = asset.tracks(withMediaType: .audio).first else { return nil }
            let outputSettings: [String : Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMBitDepthKey: 16
            ]
            let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            assetReader.add(trackOutput)
            assetReader.startReading()
            var data = Data()
            while assetReader.status == .reading {
                guard let sampleBuffer = trackOutput.copyNextSampleBuffer(), let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
                let dataLength = CMBlockBufferGetDataLength(blockBuffer)
                let sampleBytes = UnsafeMutablePointer<Int16>.allocate(capacity: dataLength)
                defer {
                    sampleBytes.deallocate()
                }
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: dataLength, destination: sampleBytes)
                data.append(Data(bytes: sampleBytes, count: dataLength))
                CMSampleBufferInvalidate(sampleBuffer)
                
            }
            if assetReader.status == .completed {
                return data
            }
            return nil
 
        } catch {
            return nil
        }
        
    }
}
