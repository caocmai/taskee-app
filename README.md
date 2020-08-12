# Taskee App
Taskee is an app that users can create and modify projects along with their tasks. 

## Description
This is a to-do type app that allows users to create and modify projects and tasks objects with a one to many relationship. This app essentially allows users to create and modify parent and child objects. More specifically, the project is the parent object and its child is the task object. There can be multiple projects and each project can have multiple tasks. 

Core Data is used to persistently store user created data, meaning data will not be lost when the application is purged from memory intentionally or by accident. 

### Features 
* CRUD(Create, Read, Update, and Delete) plus Search projects 
* CRUD(Create, Read, Update, and Delete) tasks of projects with ability to toggle between pending and completed
* Empty field validation 
* Edit/update a project/task is accessible by 3D touch (context menu)
* Core Data to persist projects and tasks 

### App Demo (gif)
![](Project%20Gif/Taskee1.gif)

### Usage
The user can create a project by giving it a name and color of their choosing to make the project easier to differentiate between them. 

The user can then create tasks for that project by giving them a title, image, and due date. These tasks can then be marked as completed by a tap gesture.

### Run Locally
Project code can be viewed locally and run in Xcode's simulator by cloning or downloading this [repo](https://github.com/caocmai/taskee-app.git).

## Built With
* [Xcode - 11.3.1](https://developer.apple.com/xcode/) - The IDE used
* [Swift - 5.1.4](https://developer.apple.com/swift/) - Programming language

## Author
* Cao Mai - [Portfolio](https://www.makeschool.com/portfolio/Cao-Mai)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
