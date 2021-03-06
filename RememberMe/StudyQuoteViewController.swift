//
//  StudyQuoteViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/5/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion
import AudioToolbox

class StudyQuoteViewController: UIViewController {

    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    let userDefaults = NSUserDefaults.standardUserDefaults()

    private struct QuoteWord {
        var text: String = ""
        var hidden: Bool = false
    }

    // MARK: - Class Variables
    @IBOutlet weak var quoteText: UITextView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    private var numWrong = 0
    private var guessIndex = 0
    private var timer = NSTimer()
    private var quoteFontSize: CGFloat = UIFont.labelFontSize() {
        didSet {
            reloadQuote(false)
        }
    }
    private var currentDuration: NSTimeInterval? {
        didSet {
            if let duration = currentDuration {
                if let label = timeLabel {
                    label.text = duration.toString()
                }
            }
        }
    }
    private var words = [QuoteWord]()
    private var revealedWords: [Int] = [Int]()
    var quote: Quote? {
        didSet {
            if let q = quote {
                words = split(q.text) { $0 == " " || $0 == "\n" }.map {
                    QuoteWord(text: $0, hidden: false)
                }
                currentDuration = q.currentTime.timeIntervalSinceReferenceDate
                var inProgress = self.userDefaults.valueForKey("inProgress") as [String]
                if !contains(inProgress, q.strID()) {
                    inProgress.insert(q.strID(), atIndex: 0)
                    self.userDefaults.setValue(inProgress, forKey: "inProgress")
                }
                let progressText = q.progressText
                if progressText.isEmpty {
                    revealedWords = [Int](0...(words.count-1))
                } else {
                    revealedWords = split(q.progressText) { $0 == "|" }.map { $0.toInt()! }
                }
            }
        }
    }
    

    @IBAction func scaleText(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            quoteFontSize *= gesture.scale
            gesture.scale = 1
        }
    }
    //MARK: - Time Functions
    
    func incrementTime() {
        currentDuration = NSTimeInterval(currentDuration! + 1.0)
    }

    private func startTimer() {
        let selector : Selector = "incrementTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: selector, userInfo: nil, repeats: true)
    }
    //MARK: - Quote Text Logic

    private func showFinishedAlert() {
        var alert = UIAlertController(title: "Finished Memorizing", message: "Congratulations! You finished remembering!", preferredStyle: UIAlertControllerStyle.Alert)
        let test: UIAlertAction = UIAlertAction(title: "Test again", style: .Default)
            { (action: UIAlertAction!) -> Void in
                self.guessIndex = 0
                self.reloadQuote(true)
        }
        let done: UIAlertAction = UIAlertAction(title: "Done", style: .Default)
            { (action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("finishStudy", sender: nil)
        }
        alert.addAction(test)
        alert.addAction(done)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func updateAverage() {
        var timeStudying: Double = userDefaults.doubleForKey("timeStudying")
        var wps: Double = userDefaults.doubleForKey("wps")
        var totalWords: Int = Int(timeStudying * wps) + words.count
        timeStudying += currentDuration!
        wps = Double(totalWords)/timeStudying
        userDefaults.setDouble(wps, forKey: "wps")
        userDefaults.setDouble(timeStudying, forKey: "timeStudying")
        userDefaults.synchronize()
    }

    private func finishRemembering() {
        if quote?.bestTime.timeIntervalSinceReferenceDate == 0.0 || quote?.bestTime.timeIntervalSinceReferenceDate > currentDuration! {
            quote?.bestTime = NSDate(timeIntervalSinceReferenceDate: currentDuration!)
        }
        timer.invalidate()
        updateAverage()
        currentDuration = NSTimeInterval(0)
        var memorized = userDefaults.valueForKey("memorized") as [String]
        memorized.insert(quote!.strID() , atIndex: 0)
        if memorized.count > 50 {
            memorized.removeLast()
        }
        userDefaults.setValue(memorized, forKey: "memorized")
        if let inProgress = userDefaults.valueForKey("inProgress") as? [String] {
            userDefaults.setValue(inProgress.filter { $0 != self.quote!.strID() }, forKey: "inProgress")
        }
        showFinishedAlert()
    }
    private func binarySearch(numbers: [Int], target: Int, low: Int, high: Int) -> Bool {
        let midpoint = (low + high)/2
        if low > high {
            return false
        }
        if numbers[midpoint] < target {
            return binarySearch(numbers, target: target, low: midpoint + 1, high: high)
        } else if numbers[midpoint] > target {
            return binarySearch(numbers, target: target, low: low, high: midpoint - 1)
        } else {
            return true
        }
    }

    private func binarySearch(numbers: [Int], target: Int) -> Bool {
        return numbers.count > 0 && binarySearch(numbers, target: target, low: numbers.startIndex, high: numbers.endIndex)
    }


    
    private func hideRandomWord() {
        if (revealedWords.count > 0) {
            let randomIndex = Int(arc4random_uniform(UInt32(revealedWords.count)))
            let randomWordIndex = revealedWords[randomIndex]
            revealedWords.removeAtIndex(randomIndex)
            words[randomWordIndex].hidden = true
        }
    }

    private func reloadQuote(animate: Bool) {
        var blackText = ""
        var greyText = ""
        for var i: Int = 0; i < guessIndex; ++i {
            blackText += words[i].text + " " //guessed words should not be hidden
        }
        for var i: Int = guessIndex + 1; i < words.count; ++i {
            let word = words[i]
            if word.hidden {
                greyText += "_____"
            } else {
                greyText += word.text
            }
            if i < words.count - 1 {
                greyText += " "
            }
        }
        var guessWord = ""
        if guessIndex < words.count {
            if words[guessIndex].hidden {
                guessWord = "_____ "
            } else {
                guessWord = words[guessIndex].text + " "
            }
        }
        var fullText: NSString = blackText + guessWord +  greyText
        var attrText = NSMutableAttributedString(string: fullText)
        let guessWordLength = countElements(guessWord)
        let blackRange = NSMakeRange(0, countElements(blackText))
        
        // Adds attributes to text
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: blackRange)
        attrText.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: quoteFontSize)!, range: NSMakeRange(0, attrText.length))
        var guessWordColor = UIColor.grayColor()
        if numWrong > 0 {
            guessWordColor = UIColor.redColor()
        }
        attrText.addAttribute(NSForegroundColorAttributeName, value: guessWordColor, range: NSMakeRange(blackRange.length, guessWordLength))
        attrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(blackRange.length + guessWordLength, countElements(greyText)))
        if animate {
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    self.quoteText.alpha = 0.0
                },
                completion: {
                    (finished: Bool) -> Void in
                    if finished {
                        self.quoteText.attributedText = attrText
                        self.quoteText.alpha = 1.0
                    }
                    
            })
        } else {
            quoteText.attributedText = attrText
        }
    }

    private func resetText() {
        guessIndex = 0
        for var i: Int = 0; i < words.count; ++i {
                words[i].hidden = true
        }
        for i in revealedWords {
            words[i].hidden = false
        }
    }

    @IBAction func valueChanged(sender: UITextField) {
        let letter = sender.text
        sender.text = ""
        if !letter.isEmpty && letter.lowercaseString[0] == words[guessIndex].text.lowercaseString[0] {
            numWrong = 0
            words[guessIndex].hidden = false
            guessIndex++
            if guessIndex == words.count {
                if revealedWords.count > 0 {
                    let min: Int = userDefaults.integerForKey("minHidden")
                    let max: Int = userDefaults.integerForKey("maxHidden")
                    let range = max - min
                    let numHidden = arc4random_uniform(UInt32(range)) + min
                    for var i: UInt32 = 0; i < numHidden; ++i {
                        hideRandomWord()
                    }
                    resetText()
                    reloadQuote(true)
                } else {
                    reloadQuote(false)
                    finishRemembering()
                }
            } else {
                reloadQuote(false)
            }
        } else {
            numWrong++
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            if numWrong >= userDefaults.integerForKey("numAttempts") {
                words[guessIndex].hidden = false
                reloadQuote(true)

            } else {
                reloadQuote(false)
            }
        }
    }
    
    
    //MARK: - Core Motion
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if userDefaults.boolForKey("shakeEnabled") {
            switch motion {
            case .MotionShake:
                hideRandomWord()
                reloadQuote(true)
            default:
                return
            }
        }
    }

    // MARK: - View Life Cycle
    override func viewWillAppear(animated: Bool) {
        titleLabel.text = quote?.title
        timeLabel.text = quote!.currentTime.timeIntervalSinceReferenceDate.toString()
        resetText()
        reloadQuote(false)
        startTimer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.becomeFirstResponder()
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
        let delimiter = "|"
        let progress =  delimiter.join(revealedWords.map {"\($0)"})
        quote!.progressText = delimiter.join(revealedWords.map {"\($0)"})
        quote!.currentTime = NSDate(timeIntervalSinceReferenceDate: currentDuration!)
        var error: NSError? = NSError()
        if !managedObjectContext.save(&error) {
            NSLog("Unresolved error: \(error), \(error!.userInfo)")
            abort()
        }
        userDefaults.synchronize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }




    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let quoteDetailViewController = destination as? QuoteDetailViewController {
            if let identifier = segue.identifier {
                if identifier == "finishStudy" {
                    quoteDetailViewController.quote = quote
                }
            }
        }
    }


}
/* Taken from http://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language */
extension NSTimeInterval {
    func toString() -> String {
        let time = self
        var elapsedTime = time
        let secondsPerMinute = 60.0
        let minutesPerHour = 60.0
        let hours = UInt8(elapsedTime/(secondsPerMinute * minutesPerHour))
        elapsedTime -= NSTimeInterval(hours) * secondsPerMinute * minutesPerHour
        let minutes = UInt8(elapsedTime/secondsPerMinute)
        elapsedTime -= NSTimeInterval(minutes) * secondsPerMinute
        let seconds = UInt8(elapsedTime)
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        return "\(strHours):\(strMinutes):\(strSeconds)"
    }
}
extension String {
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
}
