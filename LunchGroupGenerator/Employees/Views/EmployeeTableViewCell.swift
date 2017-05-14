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
    @IBOutlet var infoLabelsCollection: [UILabel]?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var jobTitleLabel: UILabel?
    @IBOutlet weak var departmentLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        if let collection = self.infoLabelsCollection
        {
            // initialize labels
            for label in collection
            { label.text = "" }
        }
    }
    
    // sets up the cell with the given object
    func tableView(tableView: UITableView, setupCellWithAny any: Any?, indexPath: IndexPath)
    {
        guard let employee = any as? NSManagedObject else
        { return }
        
        // set up employee info
        self.setupName(employee: employee)
        self.setupJobTitle(employee: employee)
        self.setupDepartment(employee: employee)
        self.setupEmail(employee: employee)
    }
}

//MARK: - Helper Functions: Initialization -
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

//MARK: - Helper Functions: Utilities -
extension EmployeeTableViewCell
{
    // sets up employee name
    fileprivate func setupName(employee: NSManagedObject)
    {
        var firstName = ""
        var lastName = ""
        
        if let firstNameValue = employee.value(forKey: EmployeeManagedObjectKey.firstName) as? String
        { firstName = firstNameValue }
        
        if let lastNameValue = employee.value(forKey: EmployeeManagedObjectKey.lastName) as? String
        { lastName = lastNameValue }
        
        self.nameLabel?.text = "\(firstName) \(lastName)"
    }
    
    // sets up employee job title
    fileprivate func setupJobTitle(employee: NSManagedObject)
    {
        if let jobTitleValue = employee.value(forKey: EmployeeManagedObjectKey.jobTitle) as? String
        { self.jobTitleLabel?.text = jobTitleValue }
    }
    
    // sets up employee department
    fileprivate func setupDepartment(employee: NSManagedObject)
    {
        if let departmentValue = employee.value(forKey: EmployeeManagedObjectKey.department) as? String
        { self.departmentLabel?.text = "@ \(departmentValue)" }
    }
    
    // sets up employee contact email
    fileprivate func setupEmail(employee: NSManagedObject)
    {
        if let emailValue = employee.value(forKey: EmployeeManagedObjectKey.email) as? String
        { self.emailLabel?.text = emailValue }
    }
}
