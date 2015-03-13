//
//  SettingTableViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/12/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var shakeToHideSwitch: UISwitch!
    @IBOutlet weak var attemptsLabel: UILabel!
    @IBOutlet weak var minHiddenLabel: UILabel!
    @IBOutlet weak var maxHiddenLabel: UILabel!
    @IBOutlet weak var minHiddenSlider: UISlider!
    @IBOutlet weak var maxHiddenSlider: UISlider!

    @IBOutlet weak var attemptsStepper: UIStepper!

    
    let studyVariables = NSUserDefaults.standardUserDefaults()

    @IBAction func incrementAttempts(sender: UIStepper) {
        let number = String(format: "%.0f", sender.value)
        attemptsLabel.text = "\(number) Attempts Before Reveal"
    }
    @IBAction func updateMinHidden(sender: UISlider) {
        minHiddenLabel.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func updateMaxHidden(sender: UISlider) {
        maxHiddenLabel.text = String(format: "%.0f", sender.value)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = true
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    override func viewWillAppear(animated: Bool) {
        shakeToHideSwitch.setOn(studyVariables.boolForKey("shakeEnabled"), animated: false)
        minHiddenSlider.value = Float(studyVariables.integerForKey("minHidden"))
        maxHiddenSlider.value = Float(studyVariables.integerForKey("maxHidden"))
        minHiddenLabel.text = String(studyVariables.integerForKey("minHidden"))
        maxHiddenLabel.text = String(studyVariables.integerForKey("maxHidden"))
        let number = studyVariables.integerForKey("numAttempts")
        attemptsLabel.text = "\(number) Attempts Before Reveal"
        attemptsStepper.value = Double(number)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        println("he's touching meeee")
        self.view.endEditing(true)
    }

    override func viewDidDisappear(animated: Bool) {
        let min = Int(minHiddenSlider.value)
        studyVariables.setInteger(min, forKey: "minHidden")
        var max = Int(maxHiddenSlider.value)
        if max < min {
            max = min
        }
        studyVariables.setInteger(max, forKey: "maxHidden")
        studyVariables.setInteger(Int(attemptsStepper.value), forKey: "numAttempts")
        studyVariables.setBool(shakeToHideSwitch.selected, forKey: "shakeEnabled")
        studyVariables.synchronize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
