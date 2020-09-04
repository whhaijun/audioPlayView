//
//  ViewController.swift
//  CMSAudio
//
//  Created by admin on 2020/9/3.
//  Copyright © 2020 Sihj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let playerView = CMSAudioView.init()
    
    
    @IBOutlet weak var audioPlayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createAVPlay()
    }

    @IBAction func addBtnClick(_ sender: UIButton) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"MP3Sample" ofType:@"mp3"];

        if self.audioPlayView.viewWithTag(10201) == nil {
            
            createAVPlay()
        }
    }
    
    func createAVPlay() {
        let path = Bundle.main.path(forResource: "MP3Sample", ofType: "mp3")!
        self.playerView.initWithPath(frame: CGRect.init(x: 10, y: 20, width: self.view.frame.size.width - 40, height: 54), path: path, audioSourceType: .AudioTypeLocal,  autoPlayStatus: nil)
        self.playerView.tag = 10201
        self.audioPlayView.addSubview(self.playerView)
        self.playerView.backgroundColor = UIColor.init(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
        self.playerView.readColor = UIColor.red
        self.playerView.roundedCornersRadius = 4
    }
    
    @IBAction func playAndPuaseBtnClick(_ sender: UIButton) {
        sender.setTitle("继续", for: .normal)
        sender.setTitle("暂停", for: .selected)
        if self.audioPlayView.viewWithTag(10201) == nil {
            createAVPlay()
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.playerView.play()
            
        }
        else {
            self.playerView.puase()
        }
    }
}

