//
//  LunchGroupTableViewCell.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

class LunchGroupTableViewCell: UITableViewCell
{
    @IBOutlet var infoLabelsCollection: [UILabel]?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var numOfEmployeesLabel: UILabel?
    @IBOutlet weak var employeeListLabel: UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // initialize labels
        if let collection = self.infoLabelsCollection
        {
            for label in collection
            { label.text = "" }
        }
    }
    
    // sets up the cell with the given object
    func tableView(tableView: UITableView, setupCellWithAny any: Any?, indexPath: IndexPath)
    {
        guard let lunchGroup = any as? NSManagedObject else
        { return }
        
        // set up lunch group info
        self.setupTitle(lunchGroup: lunchGroup)
        self.setupNumOfEmployees(lunchGroup: lunchGroup)
        self.setupEmployees(lunchGroup: lunchGroup)
    }
}

//MARK: - Helper Functions: Initialization -
extension LunchGroupTableViewCell
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

//MARK: - Helper Functions: Utilities -
extension LunchGroupTableViewCell
{
    // sets up group's title
    fileprivate func setupTitle(lunchGroup: NSManagedObject)
    {
        if let titleValue = lunchGroup.value(forKey: LunchGroupManagedObjectKey.title) as? String
        { self.titleLabel?.text = titleValue }
    }
    
    fileprivate func setupNumOfEmployees(lunchGroup: NSManagedObject)
    {
        if let numValue = lunchGroup.value(forKey: LunchGroupManagedObjectKey.numOfEmployees) as? Int
        { self.numOfEmployeesLabel?.text = "\(String(numValue)) Total" } // e.g.: 5 Total
    }
    
    fileprivate func setupEmployees(lunchGroup: NSManagedObject)
    {
        let employeesSet = lunchGroup.mutableSetValue(forKey: LunchGroupManagedObjectKey.employees)
        
        let names = employeesSet.map(
            { employeeObj -> String in
                // check for first name
                guard let employee = employeeObj as? NSManagedObject,
                    let firstName = employee.value(forKey: EmployeeManagedObjectKey.firstName) as? String else
                { return "" }
                
                // check for last name
                guard let lastName = employee.value(forKey: EmployeeManagedObjectKey.lastName) as? String,
                    let initial = lastName.capitalized.characters.first else
                { return firstName}
                
                return "\(firstName) \(initial)" // e.g.: John K
            })
        
        // comma seperated list of employee names, e.g.:  Emma A, Mary L, John K
        self.employeeListLabel?.text = names.joined(separator: ", ")
    }
}





