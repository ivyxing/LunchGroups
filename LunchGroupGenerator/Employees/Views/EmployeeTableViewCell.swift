//
//  EmployeeTableViewCell.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

class EmployeeTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var jobTitleLabel: UILabel?
    @IBOutlet weak var departmentLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    
    // sets up the cell with the given object
    func tableView(tableView: UITableView, setupCellWithAny any: Any?, indexPath: IndexPath)
    {
        guard let employee = any as? NSManagedObject else
        { return }
        
        
    }
}

//MARK: - EmployeeTableViewCell -
extension EmployeeTableViewCell
{
    // cell's identifier -> class name
    class func cellIdentifier() -> String
    {
        return String(describing: self)
    }
    
    // registers the nib for tableview
    class func registerCell(tableView: UITableView)
    {
        let identifier = self.cellIdentifier()
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
}
