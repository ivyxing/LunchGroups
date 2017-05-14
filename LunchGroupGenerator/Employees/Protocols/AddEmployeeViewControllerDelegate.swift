//
//  AddEmployeeViewControllerDelegate.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import Foundation
import CoreData

protocol AddEmployeeViewControllerDelegate: class
{
    // created new employee
    func addEmployeeViewController(controller: AddEmployeeViewController, didAddEmployee employee: NSManagedObject)
    // cancelled creation
    func addEmployeeViewControllerDidCancel(controller: AddEmployeeViewController)
}
