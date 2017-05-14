//
//  MasterViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit

enum TabBarIndex: Int
{
    case lunchGroups
    case employees
    
    static let allValues = [lunchGroups, employees]
}

class MasterViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupViewControllersAndTabs()
    }
}

//MARK: - Helper Functions: Initialization -
extension MasterViewController
{
    fileprivate func setupViewControllersAndTabs()
    {
        var controllers = Array<UIViewController>()
        
        for i in 0..<TabBarIndex.allValues.count
        {
            guard let index = TabBarIndex(rawValue: i),
                let controller = self.getFeatureController(index: index) else
            { continue }
            
            // tab bar item
            let title = self.getFeatureTitle(index: index)
            let item = UITabBarItem(title: title, image: nil, tag: i)
            
            // add the controller
            let navController = UINavigationController(rootViewController: controller)
            navController.tabBarItem = item
            controllers.append(navController)
        }
        
        // default select first item and set controllers
        self.selectedIndex = TabBarIndex.lunchGroups.rawValue
        self.setViewControllers(controllers, animated: false)
    }
}

//MARK: - Helper Functions: Utilities -
extension MasterViewController
{
    // returns the feature's controller at the given feature index
    fileprivate func getFeatureController(index: TabBarIndex) -> UIViewController?
    {
        var controller: UIViewController?
        
        switch index
        {
        case .lunchGroups:
            controller = LunchGroupsViewController.loadFromNib()
        
        case .employees:
            controller = EmployeesViewController.loadFromNib()
        }
        
        return controller
    }
    
    // returns the tab bar item title at the given feature index
    fileprivate func getFeatureTitle(index: TabBarIndex) -> String
    {
        var title = ""
        
        switch index
        {
        case .lunchGroups:
            title = NSLocalizedString("Groups", comment: "Groups")
        
        case .employees:
            title = NSLocalizedString("People", comment: "People")
        }
        
        return title
    }
}


