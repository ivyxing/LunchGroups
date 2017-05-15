//
//  LunchGroupsViewControllerTests.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/15/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import XCTest
@testable import LunchGroupGenerator

class LunchGroupsViewControllerTests: XCTestCase
{
    var lunchGroupsViewController: LunchGroupsViewController?
    
    override func setUp()
    {
        super.setUp()
        
        self.lunchGroupsViewController = LunchGroupsViewController.loadFromNib()
    }
    
    func testGenerateLunchGroups()
    {
        guard let lunchGroupsVC = self.lunchGroupsViewController else
        {
            XCTFail("Could not initialize lunch groups vc")
            return
        }
        
        // generate new groups
        self._generateNewLunchGroups(lunchGroupVC: lunchGroupsVC)
        
        // check if we actually have employees to test
        guard lunchGroupsVC.employees.count >= lunchGroupsVC.numOfEmployeesPerGroupMin else
        { return }
        
        var totalEmployees = 0
        
        // make sure every lunch group has a valid number of employees
        for lunchGroup in lunchGroupsVC.lunchGroups
        {
            if let employees = lunchGroup.value(forKey: LunchGroupManagedObjectKey.employees) as? NSMutableSet
            {
                XCTAssertLessThanOrEqual(employees.count, lunchGroupsVC.numOfEmployeesPerGroupMax)
                XCTAssertGreaterThanOrEqual(employees.count, lunchGroupsVC.numOfEmployeesPerGroupMin)
                totalEmployees += employees.count
            }
            else
            { XCTFail("No employees in this group") }
        }
        
        // make sure everyone is included
        XCTAssertEqual(lunchGroupsVC.employees.count, totalEmployees, "The employees in each group should add up to the total employees")
    }
}

//MARK: - Helper Functions -
extension LunchGroupsViewControllerTests
{
    // Generates new lunch groups
    func _generateNewLunchGroups(lunchGroupVC: LunchGroupsViewController)
    {
        if let refreshItem = lunchGroupVC.navigationItem.rightBarButtonItem
        { lunchGroupVC.didPressReGenerate(refreshItem) }
        else
        { XCTFail("Should have initialized the correct bar button item") }
    }
    
}
