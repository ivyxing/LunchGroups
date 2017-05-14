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
    let addEmployeeSegue = "AddEmployeeViewControllerSegue"
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
        
        self.registerCells()
        self.fetchEmployeeList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == self.addEmployeeSegue,
            let addEmployeeController = segue.destination as? AddEmployeeViewController
        {
            addEmployeeController.delegate = self
        }
    }
}

//MARK: - Core Data -
extension EmployeesViewController
{
    // fetchs a list of employees from Core Data
    func fetchEmployeeList()
    {
        
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
        
        return employeeCell
    }
}

//MARK: - Helper Functions: Initialization -
extension EmployeesViewController
{
    fileprivate func registerCells()
    {
        guard let tableView = self.tableView else
        { return }
        
        EmployeeTableViewCell.registerCell(tableView: tableView)
    }
}

//MARK: - AddEmployeeViewControllerDelegate -
extension EmployeesViewController: AddEmployeeViewControllerDelegate
{
    func addEmployeeViewControllerDidCancel(controller: AddEmployeeViewController)
    {
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func addEmployeeViewController(controller: AddEmployeeViewController, didAddEmployee employee: NSManagedObject)
    {
        // add to list and refresh
        self.employees.append(employee)
        self.tableView?.reloadData()
        
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
}
