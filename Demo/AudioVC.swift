//
//  AudioVC.swift
//  Demo
//
//  Created by Appinventiv on 12/1/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import AVFoundation

class AudioVC: UIViewController {

    var fileUrl:URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        fileUrl = URL(string: "https://appinventiv-development.s3.amazonaws.com/iOS/99067382-C3F3-40B8-9492-0D923C5806BB.m4a")
    }
    
    @IBAction func playClick(_ sender: UIButton) {
        playAudio()
    }
    
    
    func playAudio(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let playerItem = AVPlayerItem(url: fileUrl)
            let player = AVPlayer(playerItem: playerItem)
            player.play()
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    


}
