//
//  EmployeeDetailViewControllerDelegate.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import Foundation
import CoreData

protocol EmployeeDetailViewControllerDelegate: class
{
    // created new employee
    func employeeDetailViewController(controller: EmployeeDetailViewController, didSaveEmployeeInfo employee: NSManagedObject)
    // cancelled creation
    func employeeDetailViewControllerDidCancel(controller: EmployeeDetailViewController)
}
