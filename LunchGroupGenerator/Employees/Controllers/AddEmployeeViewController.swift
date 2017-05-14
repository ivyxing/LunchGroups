//
//  AddEmployeeViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

class AddEmployeeViewController: UITableViewController
{
    // collections
    @IBOutlet var textLabelCollection: [UILabel]?
    @IBOutlet var inputTextFieldCollection: [UITextField]?
    // labels
    @IBOutlet weak var firstNameLabel: UILabel?
    @IBOutlet weak var lastNameLabel: UILabel?
    @IBOutlet weak var jobTitleLabel: UILabel?
    @IBOutlet weak var departmentLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    // text fields
    @IBOutlet weak var firstNameTextField: UITextField?
    @IBOutlet weak var lastNameTextField: UITextField?
    @IBOutlet weak var jobTitleTextField: UITextField?
    @IBOutlet weak var departmentTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    // delegate 
    weak var delegate: AddEmployeeViewControllerDelegate?
    
    // loads the controller from storyboard
    class func loadFromNib() -> AddEmployeeViewController
    {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "EmployeesStoryboard", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? AddEmployeeViewController else
        {
            assertionFailure("Could not load \(self) from nib")
            return AddEmployeeViewController(nibName: nil, bundle: nil)
        }
        
        return controller
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localizeStrings()
    }
}

//MARK: - Actions -
extension AddEmployeeViewController
{
    // user cancelled, data is not saved
    @IBAction func didPressCancel(_ sender: Any)
    {
        self.delegate?.addEmployeeViewControllerDidCancel(controller: self)
    }
    
    // user pressed save employee info
    @IBAction func didPressSave(_ sender: Any)
    {
        self.saveEmployee()
    }
}

//MARK: - Core Data -
extension AddEmployeeViewController
{
    // Saves the employee info to Core Data
    fileprivate func saveEmployee()
    {
        
    }
}


//MARK: - Helper Functions: Initialization -
extension AddEmployeeViewController
{
    fileprivate func localizeStrings()
    {
        // localize labels
        self.firstNameLabel?.text = NSLocalizedString("First Name", comment: "First Name")
        self.lastNameLabel?.text = NSLocalizedString("Last Name", comment: "Last Name")
        self.jobTitleLabel?.text = NSLocalizedString("Job Title", comment: "Job Title")
        self.departmentLabel?.text = NSLocalizedString("Department", comment: "Department")
        self.emailLabel?.text = NSLocalizedString("Email", comment: "Email")
        
        // localize textfield placeholder strings
        self.firstNameTextField?.placeholder = NSLocalizedString("Jane", comment: "Jane")
        self.lastNameTextField?.placeholder = NSLocalizedString("Doe", comment: "Doe")
        self.jobTitleTextField?.placeholder = NSLocalizedString("iOS Engineer", comment: "iOS Engineer")
        self.departmentTextField?.placeholder = NSLocalizedString("Engineering - Mobile", comment: "Engineering - Mobile")
        self.emailTextField?.placeholder = NSLocalizedString("jdoe@apartmentlist.com", comment: "jdoe@apartmentlist.com")
    }
}
