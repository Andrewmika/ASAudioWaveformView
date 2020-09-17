//
//  ASThrottler.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 2020/9/15.
//

import Foundation

class ASThrottler {
    private let interval: TimeInterval
    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func throttle(_ block: @escaping () -> Void) {
        workItem.cancel()
        self.workItem = DispatchWorkItem {[weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = previousRun.timeIntervalSinceNow > interval ? 0 : interval
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
