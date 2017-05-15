//
//  LunchGroupsViewController.swift
//  LunchGroupGenerator
//
//  Created by Ivy Xing on 5/13/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

import UIKit
import CoreData
import GameKit

struct LunchGroupManagedObjectKey
{
    static let lunchGroupEntity = "LunchGroup"
    static let numOfEmployees   = "numOfEmployees"
    static let title            = "title"
    static let employees        = "employees"
}

class LunchGroupsViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView?
    // constants
    let numOfEmployeesPerGroupMin: Int = 3
    let numOfEmployeesPerGroupMax: Int = 5
    // data properties
    var lunchGroups = Array<NSManagedObject>() // array of lunch groups
    var employees = Array<NSManagedObject>()   // array of employees
    
    // Loads the controller from storyboard
    class func loadFromNib() -> LunchGroupsViewController
    {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "LunchGroupsStoryboard", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? LunchGroupsViewController else
        {
            assertionFailure("Could not load \(self) from nib")
            return LunchGroupsViewController(nibName: nil, bundle: nil)
        }
        
        return controller
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // setup
        self.setupTableView()
        self.registerCells()
        
        // fetch current groups
        self.fetchLunchGroups()
    }
}

//MARK: - Actions -
extension LunchGroupsViewController
{
    // User pressed regenerate groups
    @IBAction func didPressReGenerate(_ sender: Any)
    {
        // get current employees
        self.fetchEmployees()
        
        // safety check: make sure we have at least the min number of employees
        guard self.employees.count >= self.numOfEmployeesPerGroupMin else
        {
            self.showNotEnoughEmployeesAlert()
            return
        }
        
        // destructive action: let user confirm before generate new groups
        self.showGenerateNewGroupsConfirmationAlert
            {[weak self] (alertAction) in
                self?.generateNewLunchGroups()
            }
    }
}

//MARK: - Core Data -
extension LunchGroupsViewController
{
    // Fetches a list of lunch groups from Core Data
    fileprivate func fetchLunchGroups()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // initialize fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: LunchGroupManagedObjectKey.lunchGroupEntity)
        
        // execute the request
        do
        {
            self.lunchGroups = try managedContext.fetch(fetchRequest)   // save the list of lunch groups
            self.tableView?.reloadData()
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
    
    // fetchs a list of employees from Core Data
    fileprivate func fetchEmployees()
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
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
    
    // Saves a lunch group to core data
    fileprivate func saveLunchGroup(title: String, numOfEmployees: Int, employees: NSMutableSet)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // entity description
        guard let entity = NSEntityDescription.entity(forEntityName: LunchGroupManagedObjectKey.lunchGroupEntity, in: managedContext) else
        { return }
        
        // insert into context
        let lunchGroup = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // set fields
        lunchGroup.setValue(title, forKey: LunchGroupManagedObjectKey.title)
        lunchGroup.setValue(numOfEmployees, forKey: LunchGroupManagedObjectKey.numOfEmployees)
        lunchGroup.setValue(employees, forKey: LunchGroupManagedObjectKey.employees)
        
        // save context
        do
        {
            try managedContext.save()
            self.lunchGroups.append(lunchGroup)
        }
        catch let error as NSError
        { NSLog(error.localizedDescription) }
    }
    
    // Removes the lunch group from core data
    fileprivate func removeLunchGroup(lunchGorup: NSManagedObject)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        
        // get the context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // delete group
        managedContext.delete(lunchGorup)
        
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
extension LunchGroupsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lunchGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // attemp to dequeue cell
        let identifier = LunchGroupTableViewCell.cellIdentifier()
        guard let lunchGroupCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? LunchGroupTableViewCell,
            indexPath.row < self.lunchGroups.count else
        { return UITableViewCell() }
        
        // get lunch group and setup cell
        let lunchGroup = self.lunchGroups[indexPath.row]
        lunchGroupCell.tableView(tableView: tableView, setupCellWithAny: lunchGroup, indexPath: indexPath)
        lunchGroupCell.selectionStyle = .none
        
        return lunchGroupCell
    }
}

//MARK: - Helper Functions: Initialization -
extension LunchGroupsViewController
{
    fileprivate func setupTableView()
    {
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 100
        
        self.navigationItem.title = NSLocalizedString("Lunch Groups", comment: "Lunch Groups")
    }
    
    fileprivate func registerCells()
    {
        guard let tableView = self.tableView else
        { return }
        
        LunchGroupTableViewCell.registerCell(tableView: tableView)
    }
}

//MARK: - Helper Functions: Group Generation -
extension LunchGroupsViewController
{
    fileprivate func generateNewLunchGroups()
    {
        // clear old data
        self.clearData()
        
        // group identifier
        var groupNumber = 1
        
        // randomize employees order
        guard let shuffledEmployees = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.employees) as? Array<NSManagedObject> else
        { return }
        
        // calculate the remaining number of employees if every group consists of the min number of employees
        var remainingNumber = self.employees.count % self.numOfEmployeesPerGroupMin
        
        var index = 0
        while index < shuffledEmployees.count
        {
            // by default let each group have self.numOfEmployeesPerGroupMin number of employees
            var numEmployeesInGroup = self.numOfEmployeesPerGroupMin
            
            // if there are fewer than min employees "left over", append them
            if remainingNumber > 0
            {
                // append the smaller of 1.remaining and 2.difference between min and max (to make sure we dont exceed max)
                let diff = self.numOfEmployeesPerGroupMax - self.numOfEmployeesPerGroupMin
                let extraNumEmployees = min(remainingNumber, diff)
                
                // update number of employees and the remaining number
                numEmployeesInGroup += extraNumEmployees
                remainingNumber -= extraNumEmployees
            }
            
            let employeesInGroup = NSMutableSet()
            
            // add employees to group
            for currentIndex in index..<(index + numEmployeesInGroup) where (currentIndex < shuffledEmployees.count)
            {
                employeesInGroup.add(shuffledEmployees[currentIndex])
            }
            
            // save this lunch group
            let groupTitle = "Group #\(groupNumber)"
            self.saveLunchGroup(title: groupTitle, numOfEmployees: numEmployeesInGroup, employees: employeesInGroup)
            
            groupNumber += 1             // increment group identifier number
            index += numEmployeesInGroup // move index along to next group's starting point
        }
        
        self.tableView?.reloadData()
    }
    
    fileprivate func clearData()
    {
        // remove old groups from core data
        for lunchGroup in self.lunchGroups
        { self.removeLunchGroup(lunchGorup: lunchGroup) }
        
        // remove old groups from local array
        self.lunchGroups.removeAll()
    }
}

//MARK: - Helper Functions: Alerts -
extension LunchGroupsViewController
{
    // Alert: Confirm generating new lunch groups
    fileprivate func showGenerateNewGroupsConfirmationAlert(confirmAction: ((UIAlertAction)-> Void)? = nil)
    {
        // initialize alert and message
        let message = NSLocalizedString("Generate New Groups?", comment: "New groups confirmation")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // confirm option
        let confirmTitle = NSLocalizedString("Confirm", comment: "Confirm")
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default)
        { (alertAction) in
            confirmAction?(alertAction)
        }
        alert.addAction(confirmAction)
        
        // cancel option
        let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alert.addAction(cancelAction)
        
        // show alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Alert: Not enough employees to make a lunch group
    fileprivate func showNotEnoughEmployeesAlert()
    {
        // initialize alert and message
        let message = NSLocalizedString("Not enough employees! Hire some more? ;)", comment: "Not enough employees alert")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // cancel
        let cancel = NSLocalizedString("Sure", comment: "Sure")
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        //show alert
        self.present(alert, animated: true, completion: nil)
    }
}
