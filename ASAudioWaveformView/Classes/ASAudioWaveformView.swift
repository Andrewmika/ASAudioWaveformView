//
//  ASAudioWaveformView.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/15.
//

import UIKit

public class ASAudioWaveformView: UIView {
    
    public enum PositionType {
        case top
        case center
        case bottom
    }

    public enum ContentType {
        case polyLine
        case singleLine
    }
    
    public typealias DrawCompletion = (Bool) -> Void
    
    public var audioURL: URL? {
        return waveformConfig.audioURL
    }
    
    typealias LoadState = (loaded: Bool, loading: Bool)

    var waveformConfig = ASAudioWaveformConfig()
    var filteredSamples: [Float]?
    var topPoints: [CGFloat]?
    var bottomPoints: [CGFloat]?
    var throttler = ASThrottler(interval: 0.001)
    var completion: DrawCompletion?
    var loadState: LoadState = (false, false)
    
    lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    /// class method create waveform by waveform config, see ASAudioWaveformConfig
    /// - Parameter config: A configuration object that specifies certain behaviors, See ASAudioWaveformConfig for more infomation
    /// - Parameter completion: A block object to be executed when complete. This block takes a single Boolean argument that indicates whether or not the content is empty, it will be true if empty.. This parameter may be NULL.
    public static func create(frame: CGRect, _ config: (ASAudioWaveformConfig) -> Void, completion: DrawCompletion? = nil) -> ASAudioWaveformView {
        let waveformView = ASAudioWaveformView(frame: frame)
        waveformView.createWaveform(config, completion: completion)
        return waveformView
    }

    
    /// create waveform by waveform config
    /// - Parameter config: A configuration object that specifies certain behaviors, See ASAudioWaveformConfig for more infomation
    /// - Parameter completion: A block object to be executed when complete. This block takes a single Boolean argument that indicates whether or not the content is empty, it will be true if empty. This parameter may be NULL.
    public func createWaveform(_ config: (ASAudioWaveformConfig) -> Void, completion: DrawCompletion? = nil) {
        self.completion = completion
        config(waveformConfig)
        guard frame.size.height > 0, let URL = waveformConfig.audioURL else {
            if let completion = completion {
                completion(true)
            }
            return
        }
        
        loadWaveformData(from: URL)
    }
    
    
    /// Refresh waveform by audio url
    public func refreshWaveform(with audioURL: URL?) {
        guard let url = audioURL, self.audioURL != url else {
            if let completion = completion {
                completion(true)
            }
            return
        }
        waveformConfig.audioURL = audioURL
        loadWaveformData(from: url)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        throttler.throttle {[weak self] in
            guard let self = `self` else {return}
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.shapeLayer.path = self.updateWavePath()?.cgPath
            self.shapeLayer.frame = self.bounds
            CATransaction.commit()
            
            if !self.frame.equalTo(.zero), self.loadState == (false, false), let URL = self.waveformConfig.audioURL {
                self.loadWaveformData(from: URL)
            }
        }
    }
    
}

private extension ASAudioWaveformView {
    
    func loadWaveformData(from audioURL: URL) {
        loadState.loading = true
        ASAudioWaveformDataFactory.loadAudioWaveformData(from: audioURL, formateSize: (waveformConfig.maxSamplesCount, frame.height * 0.5), timeRange: waveformConfig.timeRange) { (samples, assetData) in
            self.loadState = (true, false)
            self.filteredSamples = samples
            self.drawWaveform()
        }
    }
    
    func drawWaveform() {
        guard let samples = filteredSamples, !samples.isEmpty else {
            if let completion = completion {
                shapeLayer.path = nil
                completion(true)
            }
            return
        }
        shapeLayer.frame = bounds
        buildWaveformPoints(samples)
        shapeLayer.path = updateWavePath()?.cgPath
        shapeLayer.fillColor = waveformConfig.fillColor.cgColor
        shapeLayer.strokeColor = waveformConfig.fillColor.cgColor
        
        if let completion = completion {
            completion(false)
        }
    }
    
    func buildWaveformPoints(_ samples: [Float]) {
        var topPointsTemp = [CGFloat]()
        var bottomPointsTemp = [CGFloat]()
        samples.forEach { (sample) in
            switch waveformConfig.positionType {
                
                case .top:
                    let minY = bounds.minY
                    topPointsTemp.append(minY)
                    bottomPointsTemp.append(minY + CGFloat(sample * 2))
                case .center:
                    let midY = bounds.midY
                    topPointsTemp.append(midY - CGFloat(sample))
                    bottomPointsTemp.append(midY + CGFloat(sample))
                case .bottom:
                    let maxY = bounds.maxY
                    topPointsTemp.append(maxY - CGFloat(sample * 2))
                    bottomPointsTemp.append(maxY)
            }
        }
        topPoints = topPointsTemp
        bottomPoints = bottomPointsTemp
    }
    
    func updateWavePath() -> UIBezierPath? {
        guard let topPoints = topPoints, let bottomPoints = bottomPoints else {
            return nil
        }
        let interSpace = frame.width / CGFloat(topPoints.count)
        let minX = 0
        let maxX = max(0, topPoints.count)
        let paths = UIBezierPath()
        switch waveformConfig.contentType {
            case .polyLine:
                var firstPoint: CGPoint
                switch waveformConfig.positionType {
                    case .top: firstPoint = CGPoint(x: 0, y: bounds.minY)
                    case .center: firstPoint = CGPoint(x: 0, y: bounds.midY)
                    case .bottom: firstPoint = CGPoint(x: 0, y: bounds.maxY)
                }
                paths.move(to: firstPoint)
                for i in minX..<maxX {
                    paths.addLine(to: CGPoint(x: (CGFloat(i) + 0.5) * interSpace, y: topPoints[i]))
                }
                for i in ((minX+1)..<maxX).reversed() {
                    paths.addLine(to: CGPoint(x: (CGFloat(i) + 0.5) * interSpace, y: bottomPoints[i]))
                }
                paths.close()
            case .singleLine:
                for i in minX..<maxX {
                    paths.move(to: CGPoint(x: CGFloat(i) * interSpace, y: topPoints[i]))
                    paths.addLine(to: CGPoint(x: CGFloat(i) * interSpace, y: bottomPoints[i]))
                }
        }
        return paths
    }
    
}
