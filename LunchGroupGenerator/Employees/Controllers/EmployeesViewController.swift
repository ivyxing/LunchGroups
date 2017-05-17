//
//  EmployeesViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData

struct EmployeeManagedObjectKey
{
    static let employeeEntity = "Employee"
    static let firstName      = "firstName"
    static let lastName       = "lastName"
    static let email          = "email"
    static let jobTitle       = "jobTitle"
    static let department     = "department"
}

class EmployeesViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView?
    // constants
    let employeeDetailSegue = "EmployeeDetailViewControllerSegue"
    // data properties
    var employees = Array<NSManagedObject>() // array of employees
    
    // loads the controller from storyboard
    class func loadFromNib() -> EmployeesViewController
    {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "EmployeesStoryboard", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? EmployeesViewController else
        {
            assertionFailure("Could not load \(self) from nib")
            return EmployeesViewController(nibName: nil, bundle: nil)
        }
        
        return controller
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupTableView()
        self.registerCells()
        
        if self.employees.count == 0
        {
            // fetch new list
            self.fetchEmployeeList()
        }
        else
        {
            // existing list - view only
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == self.employeeDetailSegue,
            let detailController = segue.destination as? EmployeeDetailViewController
        {
            detailController.delegate = self
        }
    }
}

//MARK: - Core Data -
extension EmployeesViewController
{
    // Fetchs a list of employees from Core Data
    func fetchEmployeeList()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // initialize fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EmployeeManagedObjectKey.employeeEntity)
        
        // execute the request
        do
        {
            self.employees = try managedContext.fetch(fetchRequest) // fetch list
            self.sortEmployees()                                   // sort list
            self.tableView?.reloadData()
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
    
    // Removes a employee from core data
    func removeEmployeeData(employee: NSManagedObject)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // delete employee
        managedContext.delete(employee)
        
        // save context
        do
        {
            try managedContext.save()
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
}

//MARK: - UITableViewDataSource -
extension EmployeesViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // attemp to dequeue cell
        let identifier = EmployeeTableViewCell.cellIdentifier()
        guard let employeeCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? EmployeeTableViewCell,
            indexPath.row < self.employees.count else
        { return UITableViewCell() }
        
        
        // get employee and setup cell
        let employee = self.employees[indexPath.row]
        employeeCell.tableView(tableView: tableView, setupCellWithAny: employee, indexPath: indexPath)
        employeeCell.selectionStyle = .none
        
        return employeeCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        { self.removeEmployee(index: indexPath.row) }
    }
}

//MARK: - UITableViewDelegate -
extension EmployeesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {   
        guard indexPath.row < self.employees.count else
        { return }
        
        // get the employee and pass to detail controller
        let employee = self.employees[indexPath.row]
        let detailController = EmployeeDetailViewController.loadFromNib()
        detailController.employee = employee
        detailController.delegate = self
       
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}

//MARK: - Helper Functions: Initialization -
extension EmployeesViewController
{
    fileprivate func setupTableView()
    {
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 100
        
        self.navigationItem.title = NSLocalizedString("Employee List", comment: "Employee List")
    }
    
    fileprivate func registerCells()
    {
        guard let tableView = self.tableView else
        { return }
        
        EmployeeTableViewCell.registerCell(tableView: tableView)
    }
}

//MARK: - Helper Functions: Utilities -
extension EmployeesViewController
{
    // Sorts current list of employees alphabetically by first name
    fileprivate func sortEmployees()
    {
        self.employees.sort
            { (employee1, employee2) -> Bool in
                // default fist names
                var firstName1 = ""
                var firstName2 = ""
                
                // check if first name value returned
                if let employee1FirstName = employee1.value(forKey: EmployeeManagedObjectKey.firstName) as? String
                { firstName1 = employee1FirstName }
                if let employee2FirstName = employee2.value(forKey: EmployeeManagedObjectKey.firstName) as? String
                { firstName2 = employee2FirstName }
                
                return firstName1 < firstName2
            }
    }
    
    // Removes an employee from both core data and local array
    fileprivate func removeEmployee(index: Int)
    {
        // check index within bounds
        guard index < self.employees.count else
        { return }
        
        // remove from core data
        let employee = self.employees[index]
        self.removeEmployeeData(employee: employee)
        
        // remove from local array
        self.employees.remove(at: index)
        self.tableView?.reloadData()
    }
}

//MARK: - EmployeeDetailViewControllerDelegate -
extension EmployeesViewController: EmployeeDetailViewControllerDelegate
{
    func employeeDetailViewController(controller: EmployeeDetailViewController, didSaveEmployeeInfo employee: NSManagedObject)
    {
        if let index = self.employees.index(of: employee)
        {
            // modified existing, update
            self.employees[index] = employee
        }
        else
        {
            // new employee! add to list and refresh
            self.employees.append(employee)
        }
        
        self.tableView?.reloadData()
        
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func employeeDetailViewController(controller: EmployeeDetailViewController, didRemoveEmployee employee: NSManagedObject)
    {
        // check index
        guard let index = self.employees.index(of: employee) else
        { return }
        
        // remove employee
        self.removeEmployee(index: index)
        
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func employeeDetailViewControllerDidCancel(controller: EmployeeDetailViewController)
    {
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
}
