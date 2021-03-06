//
//  ProjectCell.swift
//  Taskee App
//
//  Created by Cao Mai on 6/30/20.
//  Copyright © 2020 Make School. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    static var identifier = "projectCell"
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    let cellTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Kailasa", size: 20)
        return label
    }()
    
    let taskImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
//                image.contentMode = .scaleToFill
        image.layer.masksToBounds = true

        return image
    }()
    
    let taskStatusImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        //        image.contentMode = .scaleAspectFit
        let systemCheckmark = UIImage(systemName: "checkmark.circle.fill")
        let greenSystemCheckmark = systemCheckmark?.withTintColor(#colorLiteral(red: 0.3276759386, green: 0.759457171, blue: 0.1709203422, alpha: 1), renderingMode: .alwaysOriginal)
        image.image = greenSystemCheckmark
        return image
    }()
    
    let pendingTasksLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Kailasa", size: 14)
        
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func configureUIForTask(with task: Task) {
        self.contentView.addSubview(taskImage)
        self.contentView.addSubview(taskStatusImage)
        
        taskStatusImage.isHidden = task.isCompleted ? false: true
        
        if !taskStatusImage.isHidden {
            taskImage.alpha = 0.5
        }else {
            taskImage.alpha = 1.0
        }
        
        NSLayoutConstraint.activate([
            taskImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            taskImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            taskImage.widthAnchor.constraint(equalToConstant: 60),
            taskImage.heightAnchor.constraint(equalToConstant: 60),
            
            taskStatusImage.leadingAnchor.constraint(equalTo: taskImage.trailingAnchor, constant: -25),
            taskStatusImage.topAnchor.constraint(equalTo: taskImage.topAnchor, constant: -7),
            
            taskStatusImage.widthAnchor.constraint(equalToConstant: 30),
            taskStatusImage.heightAnchor.constraint(equalToConstant: 30),
            
            cellTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -1),
            cellTitleLabel.leadingAnchor.constraint(equalTo: self.taskImage.trailingAnchor, constant: 8),
            
            pendingTasksLabel.leadingAnchor.constraint(equalTo: self.taskImage.trailingAnchor, constant: 8)
        ])
        
        taskImage.layer.cornerRadius = 9
        cellTitleLabel.text = task.title
        taskImage.image = UIImage(data: task.taskImage!)
        
        pendingTasksLabel.text = task.isCompleted ? "Completed on \(dateFormatter.string(from: task.dateCompleted!))" : "Due by \(dateFormatter.string(from: task.dueDate!))"
        pendingTasksLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    internal func configureUIForProject(with project: Project) {
        self.contentView.addSubview(taskImage)
        
        
        NSLayoutConstraint.activate([
            taskImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            taskImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            taskImage.widthAnchor.constraint(equalToConstant: 30),
            taskImage.heightAnchor.constraint(equalToConstant: 30),
            
            cellTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -3),
            cellTitleLabel.leadingAnchor.constraint(equalTo: taskImage.trailingAnchor, constant: 15),
            pendingTasksLabel.leadingAnchor.constraint(equalTo: taskImage.trailingAnchor, constant: 15),
            
        ])

//        NSLayoutConstraint.activate([
//            cellTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -3),
//            cellTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
//            pendingTasksLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15)
//        ])
//
        taskImage.layer.cornerRadius = 15
        taskImage.backgroundColor = UIColor(project.color!)
        cellTitleLabel.text = project.name
        cellTitleLabel.textColor = UIColor(project.color!)
        accessoryType = .disclosureIndicator
        var pendingTaskCount = 0
        for task in project.projectTasks! {
            if (task as! Task).isCompleted == false {
                pendingTaskCount += 1
            }
        }
        
        if project.projectTasks?.count == 0 {
            pendingTasksLabel.text = "Set a task"
            pendingTasksLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.7964469178)
        }
        else if pendingTaskCount == 0 {
            pendingTasksLabel.text = "No more tasks"
            pendingTasksLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8248440974, blue: 0.8039215803, alpha: 1)
        } else {
            pendingTasksLabel.text = "\(pendingTaskCount) Pending task\(pendingTaskCount <= 1 ? "" : "s")"
            pendingTasksLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.addSubview(cellTitleLabel)
        self.contentView.addSubview(pendingTasksLabel)
        pendingTasksLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
    }
    
}
