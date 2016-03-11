//
//  NoteTakerViewController.swift
//  Note Taker
//
//  Created by Stephen DeStefano on 6/10/15.
//  Copyright (c) 2015 Stephen DeStefano. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var audioPlayer = AVAudioPlayer()
    var notesArray: [Note] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //change the height of the table row
        self.tableView.rowHeight = 65.0
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
//set the background color of the view
      // tableView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        tableView.backgroundColor = UIColor.whiteColor()
        
         }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //CREATE THE CONTEXT VAR THAT WILL BE USED TO RETRIEVE THE SAVED CORE DATA
    //this all has to be done in viewWillAppear so it shows up
    //1. the first line we create a context var and then go to the the App delegate class, and grab from that class the managedObjectContext. we will use the context var to let us save and retrieve the data...in this case, fetch or retrieve data
    //2. we create a fetch request from core data which describes the search criteria used to retrieve data
    //3. store in the sounds array the array of objects from the fetch request, cast as a Note object (which has those name and url attributes we created)
    //4. reload the table data
    //now our objects from core data are stored into the notesArray ready to be displayed,
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext! //1
        let request = NSFetchRequest(entityName: "Note")                           //2
        self.notesArray = (try! context.executeFetchRequest(request)) as! [Note] //3
        self.tableView.reloadData()  //4
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sound = notesArray[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel!.text = sound.name
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.grayColor()
        
       let font = UIFont(name: "Avenir-Book", size: 26)
        cell.textLabel?.font = font
        
        return cell
    }
    
    //THIS IS HOW TO RETRIEVE THE SOUND FROM CORE DATA AND PLAY IT
    // 1. create a sound var and set it to the row the user taps on
    // 2. create a baseString, which is just accessing the users home directory path and storing it in a baseString var
    // 3. create a pathComponents var and assign it an array, that contains the baseString (users home directory), and the sound.url (the sound associated with the row the user tapped on)
    // 4. create a session var to hold the audio context of the app, which means we are going assign certain settings for recording
    // 5. set the session to playback so the volume on the iphone just uses AVAudioSessionCategoryPlayback, and is loud, instead of using AVAudioSessionCategoryPlayAndRecord that we set in the NewNoteViewController class
    // 6. set the audioPlayer to the audioNSURL (location of the sound)
    // 7. play the sound
    // 8. deselect the row so its not highlighted anymore
    // remember, this all fires when the user taps the row

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let sound = notesArray[indexPath.row] //1
        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]   //2
        let pathComponents = [baseString, sound.url]                      //3
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)! //4
        let session = AVAudioSession.sharedInstance()   // 4
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }  // 5
        self.audioPlayer = try! AVAudioPlayer(contentsOfURL: audioNSURL) //6
        self.audioPlayer.play()  //7
        tableView.deselectRowAtIndexPath(indexPath, animated: true) // 8
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let image : UIImage = UIImage(named: "Check Mark")!
        cell!.imageView!.image = image

    
    }
    
    
    
    //DELETE A CORE DATA OBJECT, AND DELETE IT FROM THE TABLEVIEW
    //1. check if the editing style is Delete...we use a switch statement here
    //3. create an app delegate var
    //4. create a context var of type NSManagedObjectContext, assign it appDell var...now we can use the context var to delete the audio
    //5. use the context var to delete the sound object from the core data file
    //6. delete the objects from the sounds array
    //7. save all the changes in core data
    //8. remove the deleted item from the tableView
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:    // 1
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // 3
            let context: NSManagedObjectContext = appDel.managedObjectContext! // 4
            context.deleteObject(notesArray[indexPath.row] as NSManagedObject)     // 5
            notesArray.removeAtIndex(indexPath.row)                                // 6
            do {
                try context.save()
            } catch _ {
            }                                                  // 7
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade) // 8
        default:
            return
        }
    }

}


