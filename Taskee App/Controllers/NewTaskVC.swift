//
//  NewTaskVC.swift
//  Taskee App
//
//  Created by Cao Mai on 6/30/20.
//  Copyright © 2020 Make School. All rights reserved.
// testing branch

import UIKit
import CoreData

class NewTaskVC: UIViewController, UITextFieldDelegate {
    
    var parentObject: Project!
    var taskToEdit: Task?
    var coreDataStack: CoreDataStack?
    var datePicker = UIDatePicker()
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    lazy var setTitle: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Task Title"
        textField.borderStyle = .roundedRect
        //        textField.textAlignment = .center
        textField.tag = 0
        textField.font = UIFont.systemFont(ofSize: 35)
        textField.setBottomBorder()
        return textField
    }()
    
    lazy var dateTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Done By"
        //        textField.textAlignment = .center
        textField.tag = 1
        textField.font = UIFont.systemFont(ofSize: 23)
        textField.setBottomBorder()
        textField.inputView = datePicker
        return textField
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SAVE", for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let taskImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "no item image")
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 20
        
        return image
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .short
        return dateFormat
    }()
    
    //    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 920) //Step One
    
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        //        view.frame = self.view.bounds
        //        view.contentInsetAdjustmentBehavior = .never
        //        view.contentSize = contentViewSize
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let containerView : UIView = {
        let view = UIView()
        //        view.frame.size = contentViewSize
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let segementNotifyTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a reminder pior to due date (optional)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    
    let segmentItems = ["10hr", "1hr","30m","5m", "1m"]
    
    lazy var segementNotifyTime: UISegmentedControl = {
        let segment = UISegmentedControl(items: segmentItems)
        segment.addTarget(self, action: #selector(segmentNotifyTimeTapped), for: .valueChanged)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    let taskDetailDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a description to task (optional)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    
    let taskDetailDescriptionView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    var notifyTimeSelected: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupEditUI()
        setupScrollViewUI()
        datePickerToolbar()
        addToolbarToKeyboard()
        
        // ask for user permission to notify them of coming due tasks
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            //            print(error as Any)
        }
        
        UITextField.connectFields(fields: [setTitle, dateTextField]) // for better user experience when filling out forms
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        // move the root view up by the distance of keyboard height
        //        self.view.frame.origin.y = 100 - keyboardSize.height
        
        // moving the view up by scrolling 1/4 of frame height
        scrollView.setContentOffset(CGPoint(x: 0, y: view.frame.height/4), animated: true)
        
        if taskDetailDescriptionView.isFirstResponder {
            scrollView.setContentOffset(CGPoint(x: 0, y: view.frame.height/1.7), animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        //        self.view.frame.origin.y = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: view.frame.height/4), animated: true)
    }
    
    /// Setting the amount of seconds for each segment
    @objc func segmentNotifyTimeTapped() {
        switch segementNotifyTime.selectedSegmentIndex {
        case 0:
            notifyTimeSelected = 36000.0
        case 1:
            notifyTimeSelected = 3600.0
        case 2:
            notifyTimeSelected = 1800.0
        case 3:
            notifyTimeSelected = 300.0
        case 4:
            notifyTimeSelected = 60.0
        default:
            notifyTimeSelected = nil
        }
    }
    
    /// Add close toolbar on top of keyboard
    private func addToolbarToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:38, y: 100, width: 244, height: 30))
        doneToolbar.barStyle = UIBarStyle.default
        
        let hide = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: nil, action: #selector(closeKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.done, target: self, action: #selector(nextFieldTapped))
        
        doneToolbar.items = [hide, flexSpace]
        doneToolbar.sizeToFit()
        setTitle.inputAccessoryView = doneToolbar
        taskDetailDescriptionView.inputAccessoryView = doneToolbar
    }
    
    @objc func closeKeyboard() {
        setTitle.resignFirstResponder()
        taskDetailDescriptionView.resignFirstResponder()
    }
    
    @objc func nextFieldTapped() {
        dateTextField.becomeFirstResponder()
    }
    
    /// Similar to setting up projects, setting up UI of tasks to have user data if there is some
    private func setupEditUI() {
        if taskToEdit != nil { // to popluate content of the task to edit
            setTitle.text = taskToEdit?.title
            taskImageView.image = UIImage(data: (taskToEdit?.taskImage)!)
            dateTextField.text = dateFormatter.string(from: (taskToEdit?.dueDate)!)
            self.title = "Edit \(taskToEdit?.title ?? "UnNamed")"
            
            if taskToEdit!.taskDescription != "Empty String" || taskToEdit!.taskDescription != "" {
                taskDetailDescriptionView.text = taskToEdit?.taskDescription!
            }
            saveButton.setTitle("Update", for: .normal)
        } else {
            self.title = "Create A New Task"
        }
    }
    
    @objc func imageViewTapped() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func camerButtonTapped(){
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Currently not using and using setupScrollViewUI instead
    private func setupUI() {
        self.view.addSubview(setTitle)
        self.view.addSubview(dateTextField)
        self.view.addSubview(taskImageView)
        self.view.addSubview(saveButton)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        taskImageView.addGestureRecognizer(singleTap)
        
        NSLayoutConstraint.activate([
            taskImageView.widthAnchor.constraint(equalToConstant: 150),
            taskImageView.heightAnchor.constraint(equalToConstant: 150),
            taskImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120)
        ])
        
        NSLayoutConstraint.activate([
            setTitle.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: 45),
            setTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            setTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80)
        ])
        
        NSLayoutConstraint.activate([
            dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateTextField.topAnchor.constraint(equalTo: setTitle.bottomAnchor, constant: 45),
            dateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            dateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 55),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
        ])
    }
    
    private func setupScrollViewUI() {
        self.view.addSubview(scrollView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        taskImageView.addGestureRecognizer(singleTap)
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(camerButtonTapped))
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        scrollView.addSubview(containerView)
        containerView.addSubview(taskImageView)
        containerView.addSubview(setTitle)
        containerView.addSubview(dateTextField)
        containerView.addSubview(segementNotifyTime)
        containerView.addSubview(segementNotifyTimeLabel)
        containerView.addSubview(saveButton)
        containerView.addSubview(taskDetailDescriptionLabel)
        containerView.addSubview(taskDetailDescriptionView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: self.view.frame.height + 300),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
        ])
        
        NSLayoutConstraint.activate([
            taskImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            taskImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -40),
            taskImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height/2.3),
            taskImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            setTitle.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: 45),
            setTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            setTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            
            dateTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dateTextField.topAnchor.constraint(equalTo: setTitle.bottomAnchor, constant: 45),
            dateTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            dateTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            
            taskDetailDescriptionLabel.bottomAnchor.constraint(equalTo: taskDetailDescriptionView.topAnchor, constant: -2),
            taskDetailDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            
            taskDetailDescriptionView.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 75),
            taskDetailDescriptionView.heightAnchor.constraint(equalToConstant: 100),
            taskDetailDescriptionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            taskDetailDescriptionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22),
            
            segementNotifyTime.topAnchor.constraint(equalTo: taskDetailDescriptionView.bottomAnchor, constant: 65),
            segementNotifyTime.heightAnchor.constraint(equalToConstant: 45),
            segementNotifyTime.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            segementNotifyTime.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            segementNotifyTimeLabel.bottomAnchor.constraint(equalTo: segementNotifyTime.topAnchor, constant: -0),
            segementNotifyTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            
            saveButton.topAnchor.constraint(equalTo: segementNotifyTime.bottomAnchor, constant: 85),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 45),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -45),
            
        ])
    }
    
    /// Similar to New Projects, this method will either create a new Task object or save the modified Task object
    @objc func saveButtonTapped() {
        if !checkAreFieldsEmpty() {
            if taskToEdit != nil {
                taskToEdit?.setValue(setTitle.text, forKey: "title")
                taskToEdit?.setValue(taskImageView.image?.pngData(), forKey: "taskImage")
                if dateTextField.text != dateFormatter.string(from: (taskToEdit?.dueDate)!) {
                    taskToEdit?.setValue(datePicker.date, forKey: "dueDate")
                    taskToEdit?.isCompleted = false // because the if new date is different then original then change status as incomplete
                    // update the notfication with the new date
                    if notifyTimeSelected != nil {
                        NotificationHelper.addNotification(project: (taskToEdit?.parentProject?.name!)!, about: setTitle.text!, at: datePicker.date, alertBeforeSecs: notifyTimeSelected!, uniqueID: (taskToEdit?.taskID?.uuidString)!, image: taskImageView.image!)
                    }
                    taskToEdit?.parentProject!.taskCount += 1
                }
                taskToEdit?.taskDescription = taskDetailDescriptionView.text
                coreDataStack?.saveContext()
            } else {
                createNewTask()
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// Check for empty values on the form
    private func checkAreFieldsEmpty() -> Bool {
        if setTitle.text == "" {
            setTitle.layer.borderWidth = 2
            setTitle.layer.cornerRadius = 7
            setTitle.layer.borderColor = UIColor.red.cgColor
            setTitle.placeholder = "Needs Title!"
        } else {
            setTitle.layer.borderWidth = 0
            setTitle.layer.borderColor = UIColor.clear.cgColor
            setTitle.borderStyle = .roundedRect
        }
        
        if dateTextField.text == "" {
            dateTextField.layer.borderWidth = 2
            dateTextField.layer.cornerRadius = 7
            dateTextField.layer.borderColor = UIColor.red.cgColor
            dateTextField.placeholder = "Needs Date!"
        } else {
            dateTextField.layer.borderWidth = 0
            dateTextField.layer.borderColor = UIColor.clear.cgColor
            dateTextField.borderStyle = .roundedRect
        }
        
        if setTitle.text != "" && dateTextField.text != "" {
            return false // This means all fields are filled
        }
        
        return true
    }
    
    /// Add a toolbar on top of the UIDatePicker
    private func datePickerToolbar() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:38, y: 100, width: 244, height: 30))
        doneToolbar.barStyle = UIBarStyle.default
        
        let hide = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: nil, action: #selector(cancelButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonTapped))
        doneToolbar.items = [hide, flexSpace, done]
        doneToolbar.sizeToFit()
        dateTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func cancelButtonTapped(_ button: UIBarButtonItem?) {
        dateTextField.resignFirstResponder()
    }
    
    @objc func doneButtonTapped(_ button: UIBarButtonItem?) {
        dateTextField.resignFirstResponder()
        dateTextField.text = dateFormatter.string(from: datePicker.date) // shows the date in UItexfield from datepicker
    }
    
    /// Helper function to create a new Task
    private func createNewTask() {
        let newTask = Task(context: (coreDataStack?.managedContext)!)
        newTask.dueDate = datePicker.date
        newTask.isCompleted = false
        newTask.title = setTitle.text
        newTask.taskImage = taskImageView.image!.pngData()
        newTask.parentProject = parentObject
        newTask.parentProject?.projectStatus = "0Active Projects"
        newTask.taskDescription = taskDetailDescriptionView.text!
        let uniqueID = UUID()
        newTask.taskID = uniqueID
        newTask.parentProject?.taskCount += 1 // not currenlty using
        coreDataStack?.saveContext()
        
        // add to notification
        if notifyTimeSelected != nil {
            NotificationHelper.addNotification(project: (newTask.parentProject?.name)!, about: setTitle.text!, at: datePicker.date, alertBeforeSecs: notifyTimeSelected!, uniqueID: uniqueID.uuidString, image: taskImageView.image!)
        }
        
    }
    
}

// - MARK: UIImagePickerControllerDelegate

extension NewTaskVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            taskImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
}
