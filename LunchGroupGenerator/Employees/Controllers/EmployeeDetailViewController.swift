//
//  EmployeeDetailViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

class EmployeeDetailViewController: UITableViewController
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
    
    // data properties
    var employee: NSManagedObject?
    // delegate 
    weak var delegate: EmployeeDetailViewControllerDelegate?
    
    // loads the controller from storyboard
    class func loadFromNib() -> EmployeeDetailViewController
    {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "EmployeesStoryboard", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? EmployeeDetailViewController else
        {
            assertionFailure("Could not load \(self) from nib")
            return EmployeeDetailViewController(nibName: nil, bundle: nil)
        }
        
        return controller
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        // set up employee if found an existing one
        if let foundEmployee = self.employee
        { self.setupEmployee(employee: foundEmployee) }
    }
}

//MARK: - Actions -
extension EmployeeDetailViewController
{
    // user cancelled, data is not saved
    @IBAction func didPressCancel(_ sender: Any)
    {
        self.delegate?.employeeDetailViewControllerDidCancel(controller: self)
    }
    
    // user pressed save employee info
    @IBAction func didPressSave(_ sender: Any)
    {
        // make sure name is valid before saving
        guard let firstName = self.firstNameTextField?.text,
            firstName.characters.count > 0,
            let lastName = self.lastNameTextField?.text,
            lastName.characters.count > 0 else
        {
            self.showInvalidNameAlert()
            return
        }
        
        // save to core data
        self.saveEmployee()
    }
}

//MARK: - Core Data -
extension EmployeeDetailViewController
{
    // Saves the employee info to Core Data
    fileprivate func saveEmployee()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // entity description
        guard let entity = NSEntityDescription.entity(forEntityName: EmployeeManagedObjectKey.employeeEntity, in: managedContext) else
        { return }
        
        // check if new object or existing
        var employeeObj: NSManagedObject?
        
        // insert into context
        if let foundEmployee = self.employee
        { employeeObj = foundEmployee }
        else
        { employeeObj = NSManagedObject(entity: entity, insertInto: managedContext) }
        
        guard let employee = employeeObj else
        { return }
        
        if let firstName = self.firstNameTextField?.text
        { employee.setValue(firstName, forKey: EmployeeManagedObjectKey.firstName) }
        
        if let lastName = self.lastNameTextField?.text
        { employee.setValue(lastName, forKey: EmployeeManagedObjectKey.lastName) }
        
        if let jobTitle = self.jobTitleTextField?.text
        { employee.setValue(jobTitle, forKey: EmployeeManagedObjectKey.jobTitle) }
        
        if let department = self.departmentTextField?.text
        { employee.setValue(department, forKey: EmployeeManagedObjectKey.department) }
        
        if let email = self.emailTextField?.text
        { employee.setValue(email, forKey: EmployeeManagedObjectKey.email) }
        
        // save context
        do
        {
            try managedContext.save()
            self.delegate?.employeeDetailViewController(controller: self, didSaveEmployeeInfo: employee)
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
}

//MARK: - Helper Functions: Initialization -
extension EmployeeDetailViewController
{
    fileprivate func localizeStrings()
    {
        // nav item
        self.navigationItem.title = NSLocalizedString("Employee", comment: "Employee")
        
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
    
    fileprivate func setupEmployee(employee: NSManagedObject)
    {
        self.firstNameTextField?.text = employee.value(forKey: EmployeeManagedObjectKey.firstName) as? String
        self.lastNameTextField?.text = employee.value(forKey: EmployeeManagedObjectKey.lastName) as? String
        self.jobTitleTextField?.text = employee.value(forKey: EmployeeManagedObjectKey.jobTitle) as? String
        self.departmentTextField?.text = employee.value(forKey: EmployeeManagedObjectKey.department) as? String
        self.emailTextField?.text = employee.value(forKey: EmployeeManagedObjectKey.email) as? String
    }
}

//MARK: - Helper Functions: Alerts -
extension EmployeeDetailViewController
{
    // Alert: Invalid or missing first and last name
    fileprivate func showInvalidNameAlert()
    {
        // initialize alert and message
        let message = NSLocalizedString("Please enter first and last name", comment: "Invalid name message")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // cancel
        let cancel = NSLocalizedString("OK", comment: "OK")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // show alert
        self.present(alert, animated: true, completion: nil)
    }
}

