//
//  EmployeeDetailViewControllerTests.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/15/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import XCTest
@testable import LunchGroupGenerator

class EmployeeDetailViewControllerTests: XCTestCase
{
    var employeeDetailViewController: EmployeeDetailViewController?
    var employeesViewController: EmployeesViewController?
    
    override func setUp()
    {
        super.setUp()
        
        self.employeeDetailViewController = EmployeeDetailViewController.loadFromNib()
        self.employeesViewController = EmployeesViewController.loadFromNib()
    }
    
    // Tests employee creation
    func testCreateEmployees()
    {
        let numOfEmployees = 2
        
        // create a number of employees
        for _ in 0..<numOfEmployees
        { self._createEmployee() }
        
        
        guard let employeesVC = self.employeesViewController else
        {
            XCTFail("Could not initialize employees controller from nib")
            return
        }
        
        // make sure the number of employees get fetched are at least the numbers we created
        employeesVC.fetchEmployeeList()
        XCTAssertGreaterThanOrEqual(employeesVC.employees.count, numOfEmployees)
    }
    
    // Tests employee editing
    func testEditEmployee()
    {
        guard let employeesVC = self.employeesViewController else
        {
            XCTFail("Could not initialize employees controller from nib")
            return
        }
        
        // get the first employee
        guard let firstEmployee = employeesVC.employees.first else
        { return }
        
        let changedFirstName = "Test change first name"
        
        // change first name and save
        self.employeeDetailViewController?.employee = firstEmployee
        self.employeeDetailViewController?.firstNameTextField?.text = changedFirstName
        self._saveEmployee()
        
        guard let foundFirstName = firstEmployee.value(forKey: EmployeeManagedObjectKey.firstName) as? String else
        {
            XCTFail("Could not find first name")
            return
        }
        
        // make sure first name is correct
        XCTAssertEqual(foundFirstName, changedFirstName, "The first name should have been changed to the specified first name")
    }
}

//MARK: - Helper Functions -
extension EmployeeDetailViewControllerTests
{
    // Creates a single employee
    func _createEmployee()
    {
        guard let employeeDetailVC = self.employeeDetailViewController else
        {
            XCTFail("Could not initialize employee detial controller from nib")
            return
        }
        
        let firstName = "Employee Detail"
        let lastName = "Test"
        
        employeeDetailVC.firstNameTextField?.text = firstName
        employeeDetailVC.lastNameTextField?.text = lastName
        
        self._saveEmployee()
    }
    
    // Saves the employee to core data
    func _saveEmployee()
    {
        guard let employeeDetailVC = self.employeeDetailViewController else
        {
            XCTFail("Could not initialize employee detial controller from nib")
            return
        }
        
        if let saveItem = employeeDetailVC.navigationItem.rightBarButtonItem
        { employeeDetailVC.didPressSave(saveItem) }
        else
        { XCTFail("Should have initialized the correct bar button item") }
    }
}
