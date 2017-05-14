//
//  LunchGroupsViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

class LunchGroupsViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView?
    var lunchGroups = Array<NSManagedObject>() // array of lunch groups
    
    // loads the controller from storyboard
    class func loadFromNib() -> LunchGroupsViewController
    {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "LunchGroupsStoryboard", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? LunchGroupsViewController else
        {
            assertionFailure("Could not load \(self) from nib")
            return LunchGroupsViewController(nibName: nil, bundle: nil)
        }
        
        return controller
    }
}

//MARK: - UITableViewDataSource -
extension LunchGroupsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lunchGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
}
