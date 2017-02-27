//
//  SongQuizController.swift
//  Pause
//
//  Created by Tejas Nadkarni on 22/04/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

import UIKit
import AVFoundation

class SongQuizController: UIViewController {
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var Button1: UIButton!
    @IBOutlet var Button2: UIButton!
    @IBOutlet var Button3: UIButton!
    @IBOutlet var Button4: UIButton!
    @IBOutlet var ScoreLabel: UILabel!
    @IBOutlet var timerCount: UILabel!
    
    @IBOutlet var playAgainButton: UIButton!
    @IBOutlet var backHomeButton: UIButton!
    
    var imageViewObject :UIImageView =  UIImageView(frame:CGRectMake(110, 85, 150, 150))//disk image view object
    
    var audioPlayer:AVAudioPlayer!
    var rotatingRecord = false //for disk rotation
    var artistName = String()
    var songTitle = String()
    var compareArtist = false
    var compareTitle = false
    var correctAnswer = String()
    var scorePoints = 0
    var countdown = NSTimer()
    var numberOfQuestions = 0;
    var time = Int()
    var fileNameArray = ["m0", "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
                         "m11", "m12", "m13", "m14", "m15", "m16", "m17"] //songs file array
    
    var artistCollection:[NSDictionary] = []
    var songTitleCollection:[NSDictionary] = []
    
    @IBOutlet weak var bgImage: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
       initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialize() {
        
        //notifying main view controller to stop the music
        NSNotificationCenter.defaultCenter().postNotificationName("StopStartMusic", object: nil)
        
        generateArtistOptions()
        generateSongTitleOptions()
        ScoreLabel.text = "\(scorePoints)"
        
        numberOfQuestions = 0 //set number of questions to zero
        animateButtons()
        
        setRecordImage() //set record image and rotate
        
        randomQuestion() //generate random question
    }
    
    // MARK: - Quiz Questions
    //generate random questions
    func randomQuestion() {
        
        enableButtons()
        resetButtons()
        
        var randomNumber = arc4random()%2
        randomNumber += 1
        
        switch(randomNumber){
            
        case 1:
            questionLabel.text = "Guess the Artist of the Song?"
            compareArtist = true
            compareTitle = false
            break;
        case 2:
            questionLabel.text = "Guess the Title of the Song?"
            compareArtist = false
            compareTitle = true
            break;
            
        default:
            break;
        }
        
        getRandomMusic()
    }
    
    func nextQuestion(){
        numberOfQuestions += 1
        if numberOfQuestions < 7 {
            let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.randomQuestion()
                self.rotatingRecord = true
               //self.startRotateImage(self.imageViewObject)
            })
        }else{
            countdown.invalidate()
            endTheGame() //end the no of questions
        }
        
    }
    
    //MARK: - Music Files Play
    func getRandomMusic() {
    //TODO make song queue and play music
       
        if fileNameArray.count > 0{
            let randomNumber = Int(arc4random_uniform(UInt32(fileNameArray.count)))
        
            let fileName = fileNameArray[randomNumber]
            
            playMusic(fileName)
            getMetaData(fileName)
            fileNameArray.removeAtIndex(randomNumber)
           
            setButtonText()
        }else{
            //exit(0)
        }
    }
    
    //play the music files
    func playMusic(musicFile: String) {
        print("\(musicFile)")
        let audioFilePath = NSBundle.mainBundle().pathForResource(musicFile, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            audioPlayer = try? AVAudioPlayer(contentsOfURL: audioFileUrl)
            audioPlayer.play()
            if self.rotatingRecord == false {
                self.rotatingRecord = true
                self.startRotateImage(self.imageViewObject)
            }
            countdown.invalidate()
            time = Int(audioPlayer.duration)
            timerCount.text = "\(time)s"
            countdown = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
            
        } else {
            print("audio file is not found")
        }
    }
    
    func updateCounter(){
        if(time>0){
            timerCount.text = "\(String(time--))s"
        }
        else{
            timerCount.text = "0s"
            countdown.invalidate()
            stopRotateImage()
        }
    }

    
    //Fetching Meta data from music files
    func getMetaData(musicFile: String){
        
        //getting the path of the mp3 file
        let filePath = NSBundle.mainBundle().pathForResource(musicFile, ofType: "mp3")
        //transforming it to url
        let fileUrl = NSURL(fileURLWithPath: filePath!)
        //instanciating asset with url associated file
        let asset = AVAsset(URL: fileUrl) as AVAsset
        
        var titleData: NSString = ""
        var artistData: NSString = ""
        
        //using the asset property to get the metadata of file
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            if metaDataItems.commonKey == "title" {
                titleData = metaDataItems.value as! NSString
                songTitle = titleData as String
                print("title : \(songTitle)")
            }
            //getting the "Artist of the mp3 file"
            if metaDataItems.commonKey == "artist" {
                artistData = metaDataItems.value as! NSString
                 artistName = artistData as String
                 print("artist : \(artistName)")
            }
            //getting the thumbnail image associated with file
//            if metaDataItems.commonKey == "artwork" {
//                let imageData = metaDataItems.value as! NSData
//                let image2: UIImage = UIImage(data: imageData)!
//                imageView1.image = image2
//            }
        }
        
        //set correct answer
        if compareTitle == true{
            correctAnswer = songTitle
        }else if compareArtist == true{
            correctAnswer = artistName
        }
         print("correct Answer : \(correctAnswer)")
        
    }
    
    
    //MARK: - Images and Designs
    private func setRecordImage(){
        
        
        imageViewObject = UIImageView(frame:CGRectMake(110, 85, 150, 150))
        imageViewObject.image = UIImage(named:"record2")
        
        self.view.addSubview(imageViewObject)
        self.view.bringSubviewToFront(imageViewObject)
        
        rotatingRecord = true
        startRotateImage(imageViewObject)
    }
    
    // Rotate <targetView> indefinitely
    private func startRotateImage(targetView: UIView, duration: Double = 1.0) {
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveLinear, animations: {
            targetView.transform = CGAffineTransformRotate(targetView.transform, CGFloat(M_PI))
        }) { finished in if self.rotatingRecord{
            self.startRotateImage(targetView, duration: duration)
            }
        }
    }
    
    //stop rotation imges
    func stopRotateImage() {
        rotatingRecord = false
    }
    
    //MARK: - Button Actions
    @IBAction func Button1Action(sender: AnyObject) {
        disableButtons()
        if(correctAnswer == Button1.titleLabel?.text){
            correctButton(Button1)
        }else{
            wrongButton(Button1)
        }
        nextQuestion()
    }
    
    @IBAction func Button2Action(sender: AnyObject) {
        disableButtons()
        if(correctAnswer == Button2.titleLabel?.text){
            correctButton(Button2)
        }else{
           wrongButton(Button2)
        }
        nextQuestion()
    }
    
    @IBAction func Button3(sender: AnyObject) {
        disableButtons()
        if(correctAnswer == Button3.titleLabel?.text){
            correctButton(Button3)
        }else{
            wrongButton(Button3)
        }
        nextQuestion()
    }
    
    @IBAction func Button4Action(sender: AnyObject) {
        disableButtons()
        if(correctAnswer == Button4.titleLabel?.text){
            correctButton(Button4)
        }else{
            wrongButton(Button4)
        }
        nextQuestion()
    }
    
    //reset buttons background color
    func resetButtons() {
        Button1.layer.cornerRadius = 5.0;
        Button1.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button1.layer.borderWidth = 10
        Button1.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button1.tintColor = UIColor.whiteColor()
        Button1.layer.shadowOpacity = 1.0
        
        
        Button2.layer.cornerRadius = 5.0;
        Button2.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button2.layer.borderWidth = 10
        Button2.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button2.tintColor = UIColor.whiteColor()
        Button2.layer.shadowOpacity = 1.0
        
        Button3.layer.cornerRadius = 5.0;
        Button3.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button3.layer.borderWidth = 10
        Button3.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button3.tintColor = UIColor.whiteColor()
        Button3.layer.shadowOpacity = 1.0
        
        Button4.layer.cornerRadius = 5.0;
        Button4.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button4.layer.borderWidth = 10
        Button4.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button4.tintColor = UIColor.whiteColor()
        Button4.layer.shadowOpacity = 1.0
        
        playAgainButton.layer.cornerRadius = 5.0;
        playAgainButton.layer.borderColor =  UIColor(red: 255/255, green: 187/255, blue: 0/255, alpha: 1.0).CGColor
        playAgainButton.layer.borderWidth = 10
        playAgainButton.backgroundColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1.0)
        playAgainButton.tintColor = UIColor.whiteColor()
        playAgainButton.layer.shadowOpacity = 1.0
        
        backHomeButton.layer.cornerRadius = 5.0;
        backHomeButton.layer.borderColor =  UIColor(red: 255/255, green: 187/255, blue: 0/255, alpha: 1.0).CGColor
        backHomeButton.layer.borderWidth = 10
        backHomeButton.backgroundColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1.0)
        backHomeButton.tintColor = UIColor.whiteColor()
        backHomeButton.layer.shadowOpacity = 1.0
        
    }
    
    
    //MARK: -Extract All Artist
    func generateArtistOptions() {
        extractArtist("artist")
        
    }
    
    func extractArtist(fileName: String) {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        artistCollection = (jsonResult["artist"] as? [NSDictionary])!
                } catch {}
            } catch {}
        }
    }
    
    //MARK: -Extract All Song Title
    func generateSongTitleOptions() {
        extractSongTitle("songTitle")
    }
    
    func extractSongTitle(fileName: String) {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    songTitleCollection = (jsonResult["songTitle"] as? [NSDictionary])!
                
                } catch {}
            } catch {}
        }
    }
    
    
    //Mark: set Artist question buttons
    func setButtonText()  {
        var buttonArray: Array<UIButton> = [Button1, Button2, Button3, Button4]
        
        //set button 1
        var randomNumber: Int = Int(arc4random_uniform(UInt32(buttonArray.count)))
        var button : UIButton = buttonArray[randomNumber]
        if compareArtist == true {
            button.setTitle(artistName, forState: UIControlState.Normal)
            buttonArray.removeAtIndex(randomNumber)
        }else if compareTitle == true {
            button.setTitle(songTitle, forState: UIControlState.Normal)
            buttonArray.removeAtIndex(randomNumber)
        }
        
        //set button 2
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button = buttonArray[randomNumber]
        button.setTitle(getRandomName(), forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
        //set button 3
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button = buttonArray[randomNumber]
        button.setTitle(getRandomName(), forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
        //set button 4
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button = buttonArray[randomNumber]
        button.setTitle(getRandomName(), forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
    }
    
    //random selection of names for other options
    func getRandomName() -> String {
        
        var randomValue :NSDictionary = [:]
        
        if compareArtist == true {
             let randomIndex = Int(arc4random_uniform(UInt32(artistCollection.count)))
            randomValue = artistCollection[randomIndex] as NSDictionary
        }else if compareTitle == true {
             let randomIndex = Int(arc4random_uniform(UInt32(songTitleCollection.count)))
           randomValue = songTitleCollection[randomIndex] as NSDictionary
        }
        
        let isSelected = randomValue.valueForKey("isSelected") as! String
        if isSelected == "false" {
            let x = randomValue.valueForKey("name") as! String
            randomValue.setValue("true", forKey: "isSelected")
            //CHECK IF RANDOM SELECTIO  IS NOT MATCHING WITH CORRECT ANSWER
            if x == correctAnswer {
                return getRandomName()
            }else{
                return x
            }
        }else{
            return getRandomName()
        }
        
    }
    
    func correctButton(button: UIButton) {
        let t1 = Int(audioPlayer.currentTime)
        let t2 = Int(audioPlayer.duration)
        let currentSeconds = t2 - t1
        
        if t2 == currentSeconds{
            scorePoints += 10
        } else{
            scorePoints += currentSeconds * 10
        }
         ScoreLabel.text = "\(scorePoints)"
    
        
        print("current time: \(currentSeconds)")
        button.layer.borderColor = UIColor(red: 151/255, green: 226/255, blue: 83/255, alpha: 1.0).CGColor
        button.backgroundColor = UIColor(red: 87/255, green: 161/255, blue: 0/255, alpha: 1.0)
        button.tintColor = UIColor.whiteColor()
    }
    
    //wrong answer selected
    func wrongButton(button: UIButton) {
        button.layer.borderColor = UIColor(red: 233/255, green: 110/255, blue: 109/255, alpha: 1.0).CGColor
        button.backgroundColor = UIColor(red: 178/255, green: 40/255, blue: 36/255, alpha: 1.0)
        button.tintColor = UIColor.whiteColor()
    }
    
    //lock the button on selection of the answer
    private func disableButtons() {
        Button1.enabled = false
        Button2.enabled = false
        Button3.enabled = false
        Button4.enabled = false
    }
    
    //unlock the buttons to click
    private func enableButtons() {
        Button1.enabled = true
        Button2.enabled = true
        Button3.enabled = true
        Button4.enabled = true
        artistName = ""
        songTitle = ""
        correctAnswer = ""
        showButtons()
        hidePLayAgainButton()
    }
    
    //hide all the buttons
    private func hideButtons(){
        Button1.hidden = true
        Button2.hidden = true
        Button3.hidden = true
        Button4.hidden = true
    }
    
    //show all the buttons
    private func showButtons(){
        Button1.hidden = false
        Button2.hidden = false
        Button3.hidden = false
        Button4.hidden = false
    }
    
    func showPlayAgainButton(){
        playAgainButton.hidden = false
        backHomeButton.hidden = false
    }
    
    func hidePLayAgainButton(){
        playAgainButton.hidden = true
        backHomeButton.hidden = true
    }
    
    func endTheGame() {
        audioPlayer.stop()
        animatePlayButton()
        stopRotateImage()
        hideButtons()
        showPlayAgainButton()
    }
    
 
    @IBAction func playAgainButtonAction(sender: AnyObject) {
        scorePoints = 0
        numberOfQuestions = 0
        compareArtist = false
        compareTitle = false
        correctAnswer = String()
        artistName = String()
        songTitle = String()
        rotatingRecord = false
        
        fileNameArray = ["m0", "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
                         "m11", "m12", "m13", "m14", "m15", "m16", "m17"]
        artistCollection = []
        songTitleCollection = []
        
        initialize()
    }
   
    //slide in buttons animation
    func animateButtons()  {
        Button1.center.x = self.view.frame.width + 30
        Button2.center.x = self.view.frame.width + 40
        Button3.center.x = self.view.frame.width + 50
        Button4.center.x = self.view.frame.width + 60
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 15.0, initialSpringVelocity: 5, options: UIViewAnimationOptions.init(rawValue: 2), animations: ({
            self.Button1.center.x = self.view.frame.width/2
            self.Button2.center.x = self.view.frame.width/2
            self.Button3.center.x = self.view.frame.width/2
            self.Button4.center.x = self.view.frame.width/2
        }), completion: nil)
    }
    
    func animatePlayButton() {
        playAgainButton.center.x = -30
        backHomeButton.center.x = -40
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 15.0, initialSpringVelocity: 5, options: UIViewAnimationOptions.init(rawValue: 2), animations: ({
            self.playAgainButton.center.x = self.view.frame.width/2
            self.backHomeButton.center.x = self.view.frame.width/2
        }), completion: nil)
    }
}

