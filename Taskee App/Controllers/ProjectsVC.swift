//
//  ViewController.swift
//  Taskee App
//
//  Created by Cao Mai on 6/28/20.
//  Copyright © 2020 Make School. All rights reserved.
//  testing out branching

import UIKit
import CoreData

class ProjectsVC: UIViewController, NSFetchedResultsControllerDelegate {
    
    var coreDataStack = CoreDataStack()
    lazy var searchController : UISearchController = {
        let searchBar = UISearchController()
        searchBar.searchResultsUpdater = self
        searchBar.searchBar.placeholder = "Seach"
        searchBar.searchBar.delegate = self
        searchBar.obscuresBackgroundDuringPresentation  = false
        return searchBar
    }()
    lazy var table: UITableView = {
        let newTable = UITableView()
        newTable.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        newTable.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.identifier)
        newTable.frame = self.view.bounds
        newTable.delegate = self
        newTable.dataSource = self
        newTable.separatorStyle = .none
        return newTable
    }()
    let notifyEmptyTableLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Project> = {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        let nameSort = NSSortDescriptor(key: #keyPath(Project.name), ascending: true)
        let colorSort = NSSortDescriptor(key: #keyPath(Project.color), ascending: true)
        let taskCountSort = NSSortDescriptor(key: #keyPath(Project.taskCount), ascending: false)
        let projectStatusSort = NSSortDescriptor(key: #keyPath(Project.projectStatus), ascending: true)
        
        fetchRequest.sortDescriptors = [projectStatusSort, colorSort, taskCountSort, nameSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Project.projectStatus),
            cacheName: nil)
        
        fetchedResultsController.delegate = self // Use to detect changes and don't have to manually reload data
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBarAndSearch()
        configureTable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchProjects()
    }
    
    private func fetchProjects() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        table.reloadData()
    }
    
    private func setupUIForEmptyProjects(withDuration time: Double) {
        self.view.addSubview(notifyEmptyTableLabel)
        NSLayoutConstraint.activate([
            notifyEmptyTableLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            notifyEmptyTableLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        notifyEmptyTableLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
        notifyEmptyTableLabel.text = "Add A Project To Track"
        
        UIView.animate(withDuration: time, delay: 0.0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [],
                       animations: {
                        self.notifyEmptyTableLabel.transform = CGAffineTransform(scaleX: 1, y: 1)},
                       completion: nil)
    }
    
    private func configureNavBarAndSearch() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "All Projects"
        let addButton = UIBarButtonItem(title: "New Project", style: .plain, target: self, action: #selector(addProjectTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Add searchController to under navBar
        self.navigationItem.searchController = searchController
        
    }
    
    /// Helper function to fetch the object to a TableView cell
    private func configureCell(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? CustomCell else { return }
        let project = fetchedResultsController.object(at: indexPath)
        cell.configureUIForProject(with: project)
    }
    
    private func configureTable() {
        view.addSubview(table)
        
        // Refresh added to tableview
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        fetchProjects()
        table.refreshControl?.endRefreshing()
    }
    
    @objc func addProjectTapped(){
        let newProjectVC = NewProjectVC()
        newProjectVC.coreDataStack = coreDataStack
        let navController = UINavigationController(rootViewController: newProjectVC)
        self.present(navController, animated: true, completion: nil)
    }
    
}

// - MARK: UITableView
extension ProjectsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // setup proper labeling if there are no projects
        if fetchedResultsController.sections?.count == 0 {
            setupUIForEmptyProjects(withDuration: 1.20)
        } else {
            notifyEmptyTableLabel.removeFromSuperview()
        }
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    /// Configuring custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! SectionHeader
        let sectionInfo = fetchedResultsController.sections?[section].name        
        headerView.configureTitle(String(sectionInfo!))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // configure num of section headers
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath)
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    
    /// Changing the view controller after cell selected passed along the Project information
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = TasksVC()
        let project = fetchedResultsController.object(at: indexPath)
        destinationVC.selectedProject = project
        destinationVC.coreDataStack = coreDataStack
        table.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    /// Deleting the cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let project = fetchedResultsController.object(at: indexPath)
        coreDataStack.managedContext.delete(project)
        coreDataStack.saveContext()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

// - MARK: NSFetchResultsController

extension ProjectsVC {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.beginUpdates()
    }
    
    /// Configure changes to the TableView
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            table.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            table.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
//            table.reloadRows(at: [indexPath!], with: .automatic)
            fetchProjects()
//            print(indexPath)
//            let cell = table.cellForRow(at: indexPath!) as! CustomCell
//            configureCell(cell: cell, for: indexPath!)
        case .move:
            table.deleteRows(at: [indexPath!], with: .automatic)
            table.insertRows(at: [newIndexPath!], with: .automatic)
        default:
            fatalError("not valid action")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.endUpdates()
    }
    
    // update sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            table.insertSections(indexSet, with: .automatic)
        case .delete:
            table.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
    
}

// - MARK: Context Menu

extension ProjectsVC: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return nil
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let edit = UIAction(title: "Edit...") { _ in
            let editVC = NewProjectVC()
            let project = self.fetchedResultsController.object(at: indexPath)
            editVC.selectedProject = project
            editVC.coreDataStack = self.coreDataStack
            self.table.deselectRow(at: indexPath, animated: true)
            let navController = UINavigationController(rootViewController: editVC)
            
            self.present(navController, animated: true, completion: nil)
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: .none, discoverabilityTitle: .none, attributes: .destructive, state: .off) { (_) in
            let project = self.fetchedResultsController.object(at: indexPath)
            self.coreDataStack.managedContext.delete(project)
            self.coreDataStack.saveContext()
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [edit, delete])
        }
    }
}

// - MARK: Search

extension ProjectsVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        if (text?.isEmpty)! {
            // This is needed to return to displaying all projects
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(value: true)
        } else {
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "( name contains[cd] %@ )", text!)
            do {
                try self.fetchedResultsController.performFetch()
                self.table.reloadData()
                if fetchedResultsController.sections?.count == 0 {
                    notifyEmptyTableLabel.text = "Search Not Found"
                }
            } catch {}
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.resignFirstResponder()
    }
    
}
