//
//  ViewController.swift
//  Pause
//
//  Created by Jigar Panchal on 4/17/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

 
    @IBOutlet var playButton: UIButton!
    @IBOutlet var multiplayerButton: UIButton!
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setButtons()
        
        //play music
        
        let audioFilePath = NSBundle.mainBundle().pathForResource("startMusic", ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            audioPlayer = try? AVAudioPlayer(contentsOfURL: audioFileUrl)
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            
        } else {
            print("audio file is not found")
        }
        
        animateButtons()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "StopStartMusic:", name:"StopStartMusic", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //Stop Playing the music if viewController is changed
    func StopStartMusic(notification: NSNotification){ //Put stop timer code here.
        audioPlayer.stop()
    }
    
    //set buttons custom design
    func setButtons() {
        playButton.layer.cornerRadius = 5.0;
        playButton.layer.borderColor = UIColor(red: 255/255, green: 187/255, blue: 0/255, alpha: 1.0).CGColor
        playButton.layer.borderWidth = 10
        playButton.backgroundColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1.0)
        playButton.tintColor = UIColor.whiteColor()
        playButton.layer.shadowOpacity = 1.0
        playButton.alpha = 0.9
        
        multiplayerButton.layer.cornerRadius = 5.0;
        multiplayerButton.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        multiplayerButton.layer.borderWidth = 10
        multiplayerButton.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        multiplayerButton.tintColor = UIColor.whiteColor()
        multiplayerButton.layer.shadowOpacity = 1.0
        multiplayerButton.alpha = 0.9
    }
    
    //slide in buttons animation
    func animateButtons()  {
        playButton.center.x = self.view.frame.width + 30
        multiplayerButton.center.x = -30
        UIView.animateWithDuration(1.0, delay: 1.0, usingSpringWithDamping: 5.0, initialSpringVelocity: 2, options: UIViewAnimationOptions.init(rawValue: 2), animations: ({
            self.playButton.center.x = self.view.frame.width/2
            self.multiplayerButton.center.x = self.view.frame.width/2
        }), completion: nil)
    }
    
}

