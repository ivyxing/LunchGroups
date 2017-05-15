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
        self.fetchEmployeeList()
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
    // fetchs a list of employees from Core Data
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
            self.employees = try managedContext.fetch(fetchRequest)
            self.tableView?.reloadData()
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
    
    func employeeDetailViewControllerDidCancel(controller: EmployeeDetailViewController)
    {
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
}
