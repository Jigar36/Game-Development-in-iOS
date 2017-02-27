//
//  MultiPlayerController.swift
//  Pause
//
//  Created by Jigar Panchal on 4/22/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

import UIKit
import AVFoundation

class MultiPlayerController: UIViewController {

    @IBOutlet var Button11: UIButton!
    @IBOutlet var Button12: UIButton!
    @IBOutlet var Button13: UIButton!
    @IBOutlet var Button14: UIButton!
    @IBOutlet var Button21: UIButton!
    @IBOutlet var Button22: UIButton!
    @IBOutlet var Button23: UIButton!
    @IBOutlet var Button24: UIButton!
    @IBOutlet var player2ScoreLabel: UILabel!
    @IBOutlet var player1ScoreLabel: UILabel!
    
    @IBOutlet var backtoHomeButton: UIButton!
    @IBOutlet var playAgainButton: UIButton!
    @IBOutlet var player1Image: UIImageView!
    @IBOutlet var player2Image: UIImageView!
    
    @IBOutlet var player1Result: UILabel!
    @IBOutlet var player2Result: UILabel!
    
    var noOfQuestions = 0
    var player1Score = 0
    var player2Score = 0
    
    var audioPlayer:AVAudioPlayer!
    var compareArtist = false
    var compareTitle = false
    var correctAnswer = String()
    var artistName = String()
    var songTitle = String()
    var rotatingRecord = false //used to stop the recorder disk
    
    var fileNameArray = ["m0", "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
                         "m11", "m12", "m13", "m14", "m15", "m16", "m17"] //songs file array
    
    var artistCollection:[NSDictionary] = []
    var songTitleCollection:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notifying main view controller to stop the music
        NSNotificationCenter.defaultCenter().postNotificationName("StopStartMusic", object: nil)

        // Do any additional setup after loading the view.
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialize(){
       
        
        hidePLayAgainButton() //hide play again butttons
        
        generateArtistOptions()
        generateSongTitleOptions()
        
        rotateButtonText()
        setRecordImage()
        
        updateScore()// update Score to init
        
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
           // questionLabel.text = "Guess the Artist of the Song?"
            compareArtist = true
            compareTitle = false
            break;
        case 2:
            //questionLabel.text = "Guess the Title of the Song?"
            compareArtist = false
            compareTitle = true
            break;
            
        default:
            break;
        }
        
        getRandomMusic()
    }
    
    func nextQuestion(){
        noOfQuestions += 1
        if noOfQuestions < 7 {
            let triggerTime = (Int64(NSEC_PER_SEC) * 1)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.randomQuestion()
            })
        }else{
            declareWinner()
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
            exit(0)
        }
    }
    
    //play the music files
    func playMusic(musicFile: String) {
        
        let audioFilePath = NSBundle.mainBundle().pathForResource(musicFile, ofType: "mp3")

        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            audioPlayer = try? AVAudioPlayer(contentsOfURL: audioFileUrl)
            audioPlayer.play()
            
        } else {
            print("audio file is not found")
        }
    }
    
    //Fetching Meta data from music files
    func getMetaData(musicFile: String){
        print("\(musicFile)")
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
        }
        
        //set correct answer
        if compareTitle == true{
            correctAnswer = songTitle
        }else if compareArtist == true{
            correctAnswer = artistName
        }
    }
    
    //MARK: - Set button and background
    func rotateButtonText() {
        Button21.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        Button22.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        Button23.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        Button24.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        player2ScoreLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        player2Result.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        resetButtons()
    }
    
    //reset buttons background color
    func resetButtons() {
        Button11.layer.cornerRadius = 5.0;
        Button11.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button11.layer.borderWidth = 10
        Button11.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button11.tintColor = UIColor.whiteColor()
        Button11.layer.shadowOpacity = 1.0
        
        Button12.layer.cornerRadius = 5.0;
        Button12.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button12.layer.borderWidth = 10
        Button12.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button12.tintColor = UIColor.whiteColor()
        Button12.layer.shadowOpacity = 1.0
        
        Button13.layer.cornerRadius = 5.0;
        Button13.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button13.layer.borderWidth = 10
        Button13.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button13.tintColor = UIColor.whiteColor()
        Button13.layer.shadowOpacity = 1.0
        
        Button14.layer.cornerRadius = 5.0;
        Button14.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button14.layer.borderWidth = 10
        Button14.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button14.tintColor = UIColor.whiteColor()
        Button14.layer.shadowOpacity = 1.0
        
        Button21.layer.cornerRadius = 5.0;
        Button21.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button21.layer.borderWidth = 10
        Button21.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button21.tintColor = UIColor.whiteColor()
        Button21.layer.shadowOpacity = 1.0
        
        Button22.layer.cornerRadius = 5.0;
        Button22.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button22.layer.borderWidth = 10
        Button22.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button22.tintColor = UIColor.whiteColor()
        Button22.layer.shadowOpacity = 1.0
        
        Button23.layer.cornerRadius = 5.0;
        Button23.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button23.layer.borderWidth = 10
        Button23.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button23.tintColor = UIColor.whiteColor()
        Button23.layer.shadowOpacity = 1.0
        
        Button24.layer.cornerRadius = 5.0;
        Button24.layer.borderColor = UIColor(red: 100/255, green: 189/255, blue: 232/255, alpha: 1.0).CGColor
        Button24.layer.borderWidth = 10
        Button24.backgroundColor = UIColor(red: 16/255, green: 122/255, blue: 170/255, alpha: 1.0)
        Button24.tintColor = UIColor.whiteColor()
        Button24.layer.shadowOpacity = 1.0
        
        playAgainButton.layer.cornerRadius = 5.0;
        playAgainButton.layer.borderColor =  UIColor(red: 255/255, green: 187/255, blue: 0/255, alpha: 1.0).CGColor
        playAgainButton.layer.borderWidth = 10
        playAgainButton.backgroundColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1.0)
        playAgainButton.tintColor = UIColor.whiteColor()
        playAgainButton.layer.shadowOpacity = 1.0
        
        backtoHomeButton.layer.cornerRadius = 5.0;
        backtoHomeButton.layer.borderColor =  UIColor(red: 255/255, green: 187/255, blue: 0/255, alpha: 1.0).CGColor
        backtoHomeButton.layer.borderWidth = 10
        backtoHomeButton.backgroundColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1.0)
        backtoHomeButton.tintColor = UIColor.whiteColor()
        backtoHomeButton.layer.shadowOpacity = 1.0
        
        
    }
    
    //MARK: - Images and Designs
    private func setRecordImage(){
        var imageViewObject :UIImageView
        imageViewObject = UIImageView(frame:CGRectMake(110, 250, 150, 150))
        imageViewObject.image = UIImage(named:"record2")
        
        self.view.addSubview(imageViewObject)
        self.view.bringSubviewToFront(imageViewObject)
        
        backtoHomeButton.layer.zPosition = 999
        playAgainButton.layer.zPosition = 999
        
        rotatingRecord = true
        startRotateImage(imageViewObject) //start recorder disk roatate
    }
    
    // Rotate <targetView> indefinitely
    private func startRotateImage(targetView: UIView, duration: Double = 1.0) {
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveLinear, animations: {
            targetView.transform = CGAffineTransformRotate(targetView.transform, CGFloat(M_PI))
        }) { finished in if self.rotatingRecord {
            self.startRotateImage(targetView, duration: duration)
            }
        }
    }
    
    //stop rotation imges
    func stopRotateImage() {
        rotatingRecord = false
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
        var buttonArray: Array<Array<UIButton>> = [[Button11, Button21], [Button12, Button22], [Button13, Button23], [Button14, Button24]]
        
        //set button 1
        var randomNumber: Int = Int(arc4random_uniform(UInt32(buttonArray.count)))
        var button1 : UIButton = buttonArray[randomNumber][0]
        var button2 : UIButton = buttonArray[randomNumber][1]
        if compareArtist == true {
            button1.setTitle(artistName, forState: UIControlState.Normal)
            button2.setTitle(artistName, forState: UIControlState.Normal)
            buttonArray.removeAtIndex(randomNumber)
        }else if compareTitle == true {
            button1.setTitle(songTitle, forState: UIControlState.Normal)
            button2.setTitle(songTitle, forState: UIControlState.Normal)
            buttonArray.removeAtIndex(randomNumber)
        }
        
        var nameText: String = ""
        
        //set button 2
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button1 = buttonArray[randomNumber][0]
        button2 = buttonArray[randomNumber][1]
        nameText = getRandomName()
        button1.setTitle(nameText, forState: UIControlState.Normal)
        button2.setTitle(nameText, forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
        //set button 3
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button1 = buttonArray[randomNumber][0]
        button2 = buttonArray[randomNumber][1]
         nameText = getRandomName()
        button1.setTitle(nameText, forState: UIControlState.Normal)
        button2.setTitle(nameText, forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
        //set button 4
        randomNumber = Int(arc4random_uniform(UInt32(buttonArray.count)))
        button1 = buttonArray[randomNumber][0]
        button2 = buttonArray[randomNumber][1]
        nameText = getRandomName()
        button1.setTitle(nameText, forState: UIControlState.Normal)
        button2.setTitle(nameText, forState: UIControlState.Normal)
        buttonArray.removeAtIndex(randomNumber)
        
    }
    
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
    
    //MARK: - Button Actions
    @IBAction func ButtonAction11(sender: AnyObject) {
        setCorrectAnswer()
        if(correctAnswer == Button11.titleLabel?.text){
            correctButton(Button11)
            player1Score += 1
        }else{
            wrongButton(Button11)
            player2Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction12(sender: AnyObject) {
        setCorrectAnswer()
        if(correctAnswer == Button12.titleLabel?.text){
            correctButton(Button12)
            player1Score += 1
        }else{
            wrongButton(Button12)
            player2Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction13(sender: AnyObject) {
        setCorrectAnswer()
        if(correctAnswer == Button13.titleLabel?.text){
            correctButton(Button13)
            player1Score += 1
        }else{
            wrongButton(Button13)
            player2Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    
    
    @IBAction func ButtonAction14(sender: AnyObject) {
        setCorrectAnswer()
        if correctAnswer == Button14.titleLabel?.text {
            correctButton(Button14)
            player1Score += 1
        }else{
            wrongButton(Button14)
            player2Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction21(sender: AnyObject) {
         setCorrectAnswer()
        if(correctAnswer == Button21.titleLabel?.text){
            correctButton(Button21)
            player2Score += 1
        }else{
            wrongButton(Button21)
            player1Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction22(sender: AnyObject) {
        setCorrectAnswer()
        if(correctAnswer == Button22.titleLabel?.text){
            correctButton(Button22)
            player2Score += 1
        }else{
            wrongButton(Button22)
            player1Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction23(sender: AnyObject) {
        setCorrectAnswer()
        if(correctAnswer == Button23.titleLabel?.text){
            correctButton(Button23)
            player2Score += 1
        }else{
            wrongButton(Button23)
            player1Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    @IBAction func ButtonAction24(sender: AnyObject) {
         setCorrectAnswer()
        if(correctAnswer == Button24.titleLabel?.text){
            correctButton(Button24)
            player2Score += 1
        }else{
            wrongButton(Button24)
            player1Score += 1
        }
        updateScore()
        nextQuestion()
    }
    
    private func updateScore() {
        var boldText  = "\(player1Score)"
        var normalText = "/ \(player2Score)"
        
        var attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(27)]
        var boldString = NSMutableAttributedString(string:boldText, attributes:attrs)
        var attributedString = NSMutableAttributedString(string:normalText)
        
        boldString.appendAttributedString(attributedString)
        
        player1ScoreLabel.attributedText = boldString
        
        boldText  = "\(player2Score)"
        normalText = "/ \(player1Score)"
        
        attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(30)]
        boldString = NSMutableAttributedString(string:boldText, attributes:attrs)
        attributedString = NSMutableAttributedString(string:normalText)
        
        boldString.appendAttributedString(attributedString)
        player2ScoreLabel.attributedText = boldString
    }
    
    //MARK: - disable and enable buttons
    private func disableButtons() {
        Button11.enabled = false
        Button12.enabled = false
        Button13.enabled = false
        Button14.enabled = false
        Button21.enabled = false
        Button22.enabled = false
        Button23.enabled = false
        Button24.enabled = false
    }
    
    private func enableButtons() {
        showButtons()
        Button11.enabled = true
        Button12.enabled = true
        Button13.enabled = true
        Button14.enabled = true
        Button21.enabled = true
        Button22.enabled = true
        Button23.enabled = true
        Button24.enabled = true
        artistName = ""
        songTitle = ""
        correctAnswer = ""
    }
    
    //MARK: - correct and wrong answers
    func setCorrectAnswer() {
        disableButtons() //disable all buttons
        if Button11.titleLabel?.text == correctAnswer{
            actualCorrectAnswer(Button11)
            actualCorrectAnswer(Button21)
        }else if Button12.titleLabel?.text == correctAnswer {
            actualCorrectAnswer(Button12)
            actualCorrectAnswer(Button22)
            
        } else if Button13.titleLabel?.text == correctAnswer{
            actualCorrectAnswer(Button13)
            actualCorrectAnswer(Button23)
            
        } else if Button14.titleLabel?.text == correctAnswer{
            actualCorrectAnswer(Button14)
            actualCorrectAnswer(Button24)
        }
    }
    //correct answer selected
    func correctButton(button: UIButton) {
        button.layer.borderColor = UIColor(red: 151/255, green: 226/255, blue: 83/255, alpha: 1.0).CGColor
        button.backgroundColor = UIColor(red: 87/255, green: 161/255, blue: 0/255, alpha: 1.0)
        button.tintColor = UIColor.whiteColor()
    }
    
    func actualCorrectAnswer(button: UIButton){
        button.layer.borderColor = UIColor(red: 151/255, green: 226/255, blue: 83/255, alpha: 1.0).CGColor
    }
    
    //wrong answer selected
    func wrongButton(button: UIButton) {
        button.layer.borderColor = UIColor(red: 233/255, green: 110/255, blue: 109/255, alpha: 1.0).CGColor
        button.backgroundColor = UIColor(red: 178/255, green: 40/255, blue: 36/255, alpha: 1.0)
        button.tintColor = UIColor.whiteColor()
    }
    
    func declareWinner() {
        audioPlayer.stop()
        stopRotateImage()
        hideButtons()
        showPlayAgainButton()
        if player1Score > player2Score{
            player1Result.text = "Win!"
            player2Result.text = "Lose"
        }else{
            player1Result.text = "Lose"
            player2Result.text = "Win!"
        }
        if(player1Result.text == "Win!"){
            
        }
        else if(player2Result.text == "Win!"){
      
        }
    }
    
    func showButtons() {
        Button11.hidden = false
        Button12.hidden = false
        Button13.hidden = false
        Button14.hidden = false
        Button21.hidden = false
        Button22.hidden = false
        Button23.hidden = false
        Button24.hidden = false
    }
    
    func hideButtons() {
        Button11.hidden = true
        Button12.hidden = true
        Button13.hidden = true
        Button14.hidden = true
        Button21.hidden = true
        Button22.hidden = true
        Button23.hidden = true
        Button24.hidden = true
    }
    
    func showPlayAgainButton(){
        backtoHomeButton.hidden = false
        playAgainButton.hidden = false
        player1Image.hidden = false
        player2Image.hidden = false
        player1Result.hidden = false
        player2Result.hidden = false
    }
    
    func hidePLayAgainButton(){
        backtoHomeButton.hidden = true
        playAgainButton.hidden = true
        player1Image.hidden = true
        player2Image.hidden = true
        player1Result.hidden = true
        player2Result.hidden = true
    }
    
    
    @IBAction func playAgainAction(sender: AnyObject) {
        noOfQuestions = 0
        player1Score = 0
        player2Score = 0
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
    
    
}
