//
//  Player.swift
//  LYTAudioPlayer
//
//  Created by Daniel Dam Freiling on 28/04/2017.
//  Copyright © 2017 Nota. All rights reserved.
//

import Foundation
import AVFoundation

@objc
open class LYTAudioPlayer : NSObject {
    
    let observerManager = ObserverManager()
    var player: AVPlayer?;
    
    open func play() {
        NSLog("LYTAudioPlayer.play")
        do {
            // SETUP
//            NSLog("Play url: \(url.absoluteString)")
            let playerItem = AVPlayerItem(url: URL(string: "https://archive.org/download/George-Orwell-1984-Audio-book/1984-01.mp3")!)
            if #available(iOS 10, *) {
                playerItem.preferredForwardBufferDuration = TimeInterval(5)
            }
            setupItemObservers(playerItem: playerItem)
            
            self.player = AVPlayer()
            if #available(iOS 10, *) {
                self.player!.automaticallyWaitsToMinimizeStalling = false
            }
            self.player!.allowsExternalPlayback = true;
            setupPlayerObservers()
            
            // PLAY
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            self.player!.replaceCurrentItem(with: playerItem)
            self.player!.play()
        } catch {
            NSLog("Error \(error.localizedDescription)")
        }
    }
    
    func setupPlayerObservers() {
        self.observerManager.registerObserverForObject(object: self.player!, keyPath: "status") { player in
            if (self.player!.status == .readyToPlay) {
                NSLog("player READY!")
            } else if (self.player!.status == .failed) {
                NSLog("player FAILED :(")
            } else if (self.player!.status == .unknown) {
                NSLog("player status unknown")
            }
        }
        self.observerManager.registerObserverForObject(object: self.player!, keyPath: "currentTime") { obj in
            NSLog("player currentTime: \(self.player!.currentTime())")
        }
        self.observerManager.registerObserverForObject(object: self.player!, keyPath: "rate") { obj in
            NSLog("player rate: \(self.player!.rate)")
        }
//        self.observerManager.registerObserverForObject(object: self.player!, keyPath: "currentItem.duration") { obj in
//            NSLog("player currentItem.duration: \(self.player!.currentItem?.duration)")
//        }
        self.player!.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 5), queue: nil) { time in
            NSLog("Player time: \(CMTimeGetSeconds(time))")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.trackDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupItemObservers(playerItem: AVPlayerItem) {
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "status") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            if (playerItem.status == .readyToPlay) {
                NSLog("item READY!")
            } else if (playerItem.status == .failed) {
                NSLog("item FAILED :(")
            } else if (playerItem.status == .unknown) {
                NSLog("item status unknown")
            }
        }
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "duration") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            NSLog("item duration: \(CMTimeGetSeconds(playerItem.duration))")
        }
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "loadedTimeRanges") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            NSLog("item loaded time-ranges: \(playerItem.loadedTimeRanges.debugDescription)")
        }
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "playbackBufferEmpty") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            NSLog("item buffer empty: \(playerItem.isPlaybackBufferEmpty)")
        }
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "playbackBufferFull") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            NSLog("item buffer full: \(playerItem.isPlaybackBufferFull)")
        }
        self.observerManager.registerObserverForObject(object: playerItem, keyPath: "isPlaybackLikelyToKeepUp") { item in
            guard let playerItem = item as? AVPlayerItem else { return }
            NSLog("item buffer full: \(playerItem.isPlaybackLikelyToKeepUp)")
        }
    }
    
    override open func observeValue(forKeyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NSLog("\(forKeyPath.debugDescription) changed")
    }
    
    open func togglePlayback() {
        NSLog("LYTAudioPlayer.togglePlayback")
        guard let player = player else { return }
        if (player.rate > 0.0) {
            player.pause()
        } else {
            player.rate = 1.0
        }
    }
    
    open func stop() {
        NSLog("LYTAudioPlayer.stop")
        do {
            player?.pause()
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            NSLog("Error")
        }
    }
    
    func trackDidFinishPlaying() {
        NSLog("Did finish playing")
    }
}
