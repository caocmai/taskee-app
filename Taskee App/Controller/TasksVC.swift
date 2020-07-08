//
//  TasksVC.swift
//  Taskee App
//
//  Created by Cao Mai on 6/30/20.
//  Copyright © 2020 Make School. All rights reserved.
//

import UIKit
import CoreData

class TasksVC: UIViewController, UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return nil
    }
    
    
    var selectedProject: Project? {
        didSet{
            //            self.loadItems()
        }
    }
    var tasks = [Task]()
    //    var managedContext: NSManagedObjectContext?
    //    var coredataSTack = CoreDataStack()
    var coreDataStack: CoreDataStack!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    let taskTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSegmentControl()
        
        self.configureNavBar()
        //        let tasks = selectedProject?.projectTasks[0] as? Task
        //        print(selectedProject?.projectTasks)
        self.configureTable()
        //        self.loadItems()
        getPendingTasks()
        //        print("passed coredata", managedContext)
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.loadItems()
        if segmentControl.selectedSegmentIndex == 0 {
            getPendingTasks()
        } else {
            getFinshedTasks()
        }
        self.taskTable.reloadData()
    }
    
    func getPendingTasks() {
        let categoryPredicate = NSPredicate(format: "status = false")
        coreDataStack.fetchTasks(predicate: categoryPredicate, selectedProject: (selectedProject?.name)!) { results in
            switch results {
            case .success(let tasks):
                self.tasks = tasks
                self.taskTable.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getFinshedTasks() {
        let categoryPredicate = NSPredicate(format: "status = true")
        coreDataStack.fetchTasks(predicate: categoryPredicate, selectedProject: (selectedProject?.name)!) { results in
            switch results {
            case .success(let tasks):
                self.tasks = tasks
                self.taskTable.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addSegmentControl() {
        let segmentItems = ["Pending", "Finished"]
        segmentControl = UISegmentedControl(items: segmentItems)
        //       control.frame = CGRect(x: 10, y: 250, width: (self.view.frame.width - 20), height: 50)
        segmentControl.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        view.addSubview(segmentControl)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            segmentControl.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20.0),
            segmentControl.heightAnchor.constraint(equalToConstant: 45.0)
            
        ])
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            // First segment tapped
            print("one")
            getPendingTasks()
        case 1:
            // Second segment tapped
            print("two")
            getFinshedTasks()
            
            
        default:
            break
        }
    }
    
    private func configureNavBar() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "\(selectedProject!.name ?? "Unnamed") Tasks"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addTaskTapped(){
        //        let newTask = Task(context: self.coreData)
        //        newTask.dueDate = Date()
        //        newTask.status = false
        //        newTask.title = "Other task"
        //        newTask.taskImage = UIImage(named: "mango")?.pngData()
        //        newTask.parentProject = self.selectedProject
        //        coreDataStack.saveContext()
        
        let destinationVC = NewTaskVC()
        //        destinationVC.managedContext = coreDataStack.managedContext
        destinationVC.coreDataStack = coreDataStack
        destinationVC.parentObject = selectedProject
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
        
        
    }
    
    func configureTable() {
        self.taskTable.delegate = self
        self.taskTable.dataSource = self
        self.taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(taskTable)
        //        self.taskTable.frame = view.bounds
        self.taskTable.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            self.taskTable.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor),
            self.taskTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            self.taskTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            self.taskTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        
    }
    
    //    func loadItems(with request: NSFetchRequest<Task> = Task.fetchRequest(), predicate: NSPredicate? = nil) {
    //
    //        let categoryPredicate = NSPredicate(format: "parentProject.name MATCHES %@", selectedProject!.name!)
    //
    //
    //
    //        if let addtionalPredicate = predicate {
    //            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
    //        } else {
    //            request.predicate = categoryPredicate
    //        }
    //
    //
    //        do {
    //            tasks = try managedContext!.fetch(request)
    //        } catch {
    //            print("Error fetching data from context \(error)")
    //        }
    //
    //        taskTable.reloadData()
    //
    //    }
    
    
}

extension TasksVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //        cell.textLabel!.text = dateFormatter.string(from: tasks[indexPath.row].dueDate!)
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.title
        cell.accessoryType = task.status ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].status = !tasks[indexPath.row].status
        tableView.deselectRow(at: indexPath, animated: true)
        
        coreDataStack.saveContext()
        taskTable.reloadData()
        //        test()
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        self.coreDataStack.managedContext.delete(task)
        self.tasks.remove(at: indexPath.row)
        self.taskTable.deleteRows(at: [indexPath], with: .fade)
        self.coreDataStack.saveContext()
    }
    
    
}


extension TasksVC {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            let preview = PreviewViewController()
            let object = self.tasks[indexPath.row]
            preview.labeltest.text = "MOney"
            preview.imageView.image = UIImage(data: object.taskImage!)
            return preview
        }) { _ -> UIMenu? in
            let action = UIAction(title: "Edit", image: nil) { action in
                self.dismiss(animated: false, completion: nil)
                let editVC = NewTaskVC()
                editVC.taskToEdit = self.tasks[indexPath.row]
                editVC.coreDataStack = self.coreDataStack
                self.navigationController?.pushViewController(editVC, animated: true)
                
            }
            return UIMenu(title: "Menu", children: [action])
        }
        return configuration
    }
    
}


class PreviewViewController: UIViewController {
    
    var labeltest = UILabel()
    var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    
    //    static func controller() -> PreviewViewController {
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        let controller = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
    //        return controller
    //    }
}
