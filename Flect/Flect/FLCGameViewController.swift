import UIKit
import SpriteKit

enum LevelError: ErrorType {
    case InvalidLevel
}

class FLCGameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, LevelDelegate {
    // MARK: - Constants
    static let lastPlayedLevelKey = "FLCLastPlayedLevel"

    // MARK: - Properties
    /// The view in which the game is actually presented.
    @IBOutlet weak var gameView: SKView! = nil

    /// The levels loaded from JSON when the view controller is loaded up.
    var levels: [Level] = []

    /// The index of the current level.
    var currentLevel: Int = 0

    /// The collection view which shows the collection of levels available for play.
    @IBOutlet weak var levelPicker: UICollectionView! = nil

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        let dataURL = NSBundle.mainBundle().URLForResource("GameData", withExtension: "json")
        guard dataURL != nil else {
            print("Could not get URL for GameData.json")
            return
        }

        let data = NSData(contentsOfURL: dataURL!)
        guard data != nil else {
            fatalError("Unable to load data from \(dataURL!)")
        }

        do {
            self.levels = []
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
            for representation in (json as! [Dictionary<String, AnyObject>]) {
                let level = try Level(size: self.view.frame.size, json: representation)
                level.backgroundColor = try! UIColor(hexRepresentation: "#ecf0f1")
                level.scaleMode = .AspectFit
                self.levels.append(level)
            }
        } catch {
            fatalError("Unable to load levels due to error: \(error)")
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.currentLevel = userDefaults.integerForKey(FLCGameViewController.lastPlayedLevelKey)
        self.playLevel(self.currentLevel)
    }

    // MARK: - Playing Levels
    /**
     Plays the level at the given index
     
     - parameter level: The index of the level to play.
     */
    func playLevel(level: Int) {
        // Present the level.
        self.currentLevel = level
        let levelCopy = (self.levels[self.currentLevel].copy() as! Level)
        levelCopy.levelDelegate = self
        self.gameView.presentScene(levelCopy)

        // Cache the level which was just loaded.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(currentLevel, forKey: FLCGameViewController.lastPlayedLevelKey)
        userDefaults.synchronize()
    }

    @IBAction func resetLevel() {
        playLevel(self.currentLevel)
    }

    @IBAction func displayLevelPicker() {
        self.levelPicker.reloadData()

        var frame = CGRectInset(self.view.frame, 10, 10)
        frame.origin.y = frame.size.height
        self.levelPicker.frame = frame
        self.levelPicker.hidden = false

        frame = CGRectInset(self.view.frame, 10, 10)
        UIView.animateWithDuration(0.25) {
            self.levelPicker.frame = frame
        }
    }

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.levels.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FLCGameViewControllerLevelPickerCell", forIndexPath: indexPath)
        let label = cell.contentView.subviews[0] as! UILabel
        label.text = "\(indexPath.item + 1)"

        if indexPath.item == self.currentLevel {
            cell.layer.borderColor = (try! UIColor(hexRepresentation: "#2ecc71")).CGColor
            cell.layer.borderWidth = 3
        } else {
            cell.layer.borderWidth = 0
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate Methods
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        cell.layer.borderColor = (try! UIColor(hexRepresentation: "#27ae60")).CGColor
        cell.layer.borderWidth = 3
        return true
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        if indexPath.item == self.currentLevel {
            cell.layer.borderColor = (try! UIColor(hexRepresentation: "#2ecc71")).CGColor
            cell.layer.borderWidth = 3
        } else {
            cell.layer.borderWidth = 0
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let level = indexPath.item

        UIView.animateWithDuration(0.25, animations: { self.levelPicker.alpha = 0 }) { (_) in
            self.levelPicker.hidden = true
            self.levelPicker.alpha = 1

            if self.currentLevel != level {
                self.playLevel(level)
            }
        }
    }
    
    // MARK: - User Progress
    func userDidCompleteLevel(level: Level) {
        level.levelDelegate = nil

        // Loop around so we're only ever presenting valid levels.
        self.currentLevel += 1
        if self.currentLevel >= self.levels.count {
            self.currentLevel = 0
        }

        playLevel(self.currentLevel)
    }
    
    func userDidLoseLevel(level: Level) {
        level.levelDelegate = nil
        resetLevel()
    }
}
