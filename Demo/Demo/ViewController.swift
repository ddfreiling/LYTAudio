//
//  ViewController.swift
//  Demo
//
//  Created by Daniel Dam Freiling on 28/04/2017.
//  Copyright © 2017 Nota. All rights reserved.
//

import UIKit
import AVFoundation
import LYTAudioPlayer

class ViewController: UIViewController {
    
    let player = LYTAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playTap(_ sender: UIButton) {
        NSLog("Play Tap")
        
        player.play()//url: URL(string: "https://archive.org/download/George-Orwell-1984-Audio-book/1984-01.mp3")!)
    }
    
    @IBAction func stopTap(_ sender: UIButton) {
        player.stop()
    }

    @IBAction func togglePlayTap(_ sender: UIButton) {
        player.togglePlayback()
    }
}

