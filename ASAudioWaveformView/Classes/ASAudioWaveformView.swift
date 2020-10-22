//
//  ASAudioWaveformView.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/15.
//

import UIKit


public class ASAudioWaveformConfig {
    var positionType: ASAudioWaveformView.PositionType = .center
    var contentType: ASAudioWaveformView.ContentType = .polyLine
    var fillColor: UIColor = .yellow
    var audioURL: URL?
    var maxSamplesCount: Int = 600
    
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
}

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
    
    var waveformConfig = ASAudioWaveformConfig()
    var filteredSamples: [Float]?
    var topPoints: [CGFloat]?
    var bottomPoints: [CGFloat]?
    var throttler = ASThrottler(interval: 0.001)
    var completion: DrawCompletion?
    
    public private(set) var audioURL: URL?
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
        guard !frame.size.equalTo(.zero), let URL = waveformConfig.audioURL else {
            if let completion = completion {
                completion(true)
            }
            return
        }
        ASAudioWaveformDataFactory.loadAudioWaveformData(from: URL, formateSize: (waveformConfig.maxSamplesCount, frame.height * 0.5)) { (samples, assetData) in
            self.filteredSamples = samples
            self.drawWaveform()
        }
        
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
        ASAudioWaveformDataFactory.loadAudioWaveformData(from: url, formateSize: (waveformConfig.maxSamplesCount, frame.height * 0.5)) { (samples, waveData) in
            self.filteredSamples = samples
            self.drawWaveform()
        }
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
        }
    }
    
}

private extension ASAudioWaveformView {
    
    func drawWaveform() {
        guard let samples = filteredSamples, !samples.isEmpty else {
            if let completion = completion {
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
