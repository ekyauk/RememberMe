//
//  RememberMeTabViewController.swift
//  RememberMe
//
//  Created by Edric Kyauk on 3/13/15.
//  Copyright (c) 2015 Edric Kyauk. All rights reserved.
//

import UIKit
import CoreData
class RememberMeTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if let title = item.title {
            if title == "Favorites" {
                selectedViewController = viewControllers?[2] as UIViewController?
                var destination = selectedViewController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController
                }
                if let viewController = destination as? QuotesTableViewController {
                    viewController.quotes = [[Quote]]()
                    let favoritesArr = fetchQuotesFromKey("favorites")
                    viewController.quotes.insert(favoritesArr, atIndex: 0)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
