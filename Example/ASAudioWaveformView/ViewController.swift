//
//  ViewController.swift
//  ASAudioWaveformView
//
//  Created by Andrew Shen on 09/15/2020.
//  Copyright (c) 2020 Andrew Shen. All rights reserved.
//

import UIKit
import ASAudioWaveformView

class ViewController: UIViewController {
    var wave: ASAudioWaveformView!
    @IBOutlet weak var wave1: ASAudioWaveformView!
    @IBOutlet weak var wave2: ASAudioWaveformView!
    @IBOutlet weak var wave3: ASAudioWaveformView!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        wave = ASAudioWaveformView.create(frame: CGRect(x: 0, y: 40, width: view.frame.width, height: 100)) { (config) in
            let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
            config.audioURL(url).maxSamplesCount(500).fillColor(.systemTeal)
        }
        wave.backgroundColor = .blue
        self.view.addSubview(wave)
        
        wave1.createWaveform { (config) in
            let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
            config.audioURL(url).positionType(.top).fillColor(.green)
        }
        
        wave2.createWaveform { (config) in
            let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
            config.audioURL(url).positionType(.bottom).fillColor(.yellow)
        }
        
        wave3.createWaveform { (config) in
            let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
            config.audioURL(url).contentType(.singleLine).maxSamplesCount(300).fillColor(.red)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func replaceAudio(_ sender: Any) {
        let url = Bundle.main.url(forResource: "test1", withExtension: "m4a")
        wave.refreshWaveform(with: url)
        wave1.refreshWaveform(with: url)
        wave2.refreshWaveform(with: url)
        wave3.refreshWaveform(with: url)
    }
    
    @IBAction func zoom(_ sender: Any) {
        wave.frame = CGRect(x: wave.frame.origin.x - 25, y: 40, width: wave.frame.width + 50, height: 100)
        stackWidth.constant = wave.frame.width + 50
    }
    
}

