//
//  NewNoteViewController.swift
//  Note Taker
//
//  Created by Stephen DeStefano on 6/10/15.
//  Copyright (c) 2015 Stephen DeStefano. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NewNoteViewController: UIViewController {
    
    
    
    func updateAudioMeter(timer: NSTimer){
        if audioRecorder.recording {
        
        let dFormat = "%02d"
        let min:Int = Int(audioRecorder.currentTime / 60)
        let sec:Int = Int(audioRecorder.currentTime % 60)
        let timeString = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timeLabel.text = timeString
            audioRecorder.updateMeters()
            let averageAudio = audioRecorder.averagePowerForChannel(0) * -1
            let peakAudio = audioRecorder.peakPowerForChannel(0) * -1
            let progressView1Average = Int(averageAudio)    //   / 100.0  divide if using a float
            let progressView2Peak = Int(peakAudio) //   / 100.0  divide if using a float
            averageRadial(progressView1Average, peak: progressView2Peak)
            
            
        }else if !audioRecorder.recording {
             let mic = UIImage(named: "mic_no_record.png") as UIImage!
             recordOutlet.setImage(mic, forState: .Normal)
            averageImageView.image = UIImage(named:"average0radio.png")
            peakImageView.image = UIImage(named:"peak0radio.png")
            crossfadeTransition()
        }
     }
    
    func averageRadial (average: Int, peak: Int) {
        
        switch average {
        case average:
            averageImageView.image = UIImage(named:"average\(String(average))radio")
            
        default:
            averageImageView.image = UIImage(named:"average10radio.png")
        }
        
        switch peak {
        case peak:
            peakImageView.image = UIImage(named:"peak\(String(peak))radio")
            
        default:
            peakImageView.image = UIImage(named:"peak10radio.png")
        }
        
        crossfadeTransition()
    }
    
    func crossfadeTransition() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.01
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.addAnimation(transition, forKey: nil)
    }
    
    
    //required init
    // Setting up an audio recorder takes a little bit more work than setting up an audio player
    // we need to initialize the recorder components before we can use them
    // 1. create a baseString, which is just accessing the users home directory path and storing it in baseString
    // 2. the  NSUUID().UUIDString call is a string formatter that creates unique strings, we assign it to the audioURL so the audio files are unique, and just add the file type to the end of it
    // 3. create a pathComponents var and assign it an array, that contains the baseString (users home director), and the audioURL
    // 4. create an NSURL object, and put in it the pathComponents var (which has the baseString and audioURL)
    // 5. create a session var to hold the audio context of the app, which means we are going assign certain settings for recording
    // 6. add to the session var the type of recording session we want..here its PlayAndRecord
    // 7. create a recordSettings var thats of type dictionary, and can hold any object
    // 8. add to the recordSettings var an MPEG audio format
    // 9. add to the recordSettings var an audio sample rate 4100.0
    // 10.add to the recordSettings var the number of channels...an Int of 2
    // 11. assign to the audioRecorder the audioNSURL, which has the path of the recording, and record settings we just set in the recordSettings var (basically all the info we created above gets put into the audioRecorder now)
    // 12. set the audio metering to true
    // 13. finally we call the prepareToRecord() which creates an audio file and prepares the system for recording.
    required init?(coder aDecoder: NSCoder) {
        
        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]  // 1
        self.audioURL = NSUUID().UUIDString + ".m4a"                     // 2
        let pathComponents = [baseString, self.audioURL]                 // 3
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)! // 4
        let session = AVAudioSession.sharedInstance()                    // 5
        
        let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)), //7
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 2),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue)),
            AVEncoderBitRateKey : NSNumber(int: Int32(320000))]
        

        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord) // 6
           
        } catch _ {
            
        }
        
        
        self.audioRecorder = try! AVAudioRecorder(URL: audioNSURL, settings: recordSettings) // 11
        
        self.audioRecorder.meteringEnabled = true                        // 12
        self.audioRecorder.prepareToRecord()                             // 13
        
        // Super init gets set below...we call the inits super class to access its functionality here (has to do with subclassing)
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var recordOutlet: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var peakImageView: UIImageView!
    @IBOutlet weak var averageImageView: UIImageView!
    
    
    var audioRecorder: AVAudioRecorder
    var audioURL: String
    let timeInterval:NSTimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let str = NSAttributedString(string: "New note...", attributes: [NSForegroundColorAttributeName:UIColor(red: 175.0/255.0, green: 175.0/255.0, blue: 175.0/255.0, alpha: 1.0)])
        noteTextField.attributedPlaceholder = str
        
        recordOutlet.layer.shadowOpacity = 1.0
        recordOutlet.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
  
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //HOW TO SAVE THE SOUND AND LABEL TEXT TO CORE DATA
    // 1. the first line we create a context var and then go to the the App delegate class, and grab from that class the managedObjectContext. we use the context var to let us save and retrieve the data...in this case, save data
    // 2. we create the new core data note variable, and pass in the context var (the "Note" entity name has to match exactly what we created in the core data file)
    // 3. store the users typed text into the core data name property of the newly created note var (core data calls properties attributes)
    // 4. set the audioURL string we created above to the core data url attribute (attribute and property are synomonous)
    // 5. Save sound url and name to core data
    // 6. Dismiss ViewController
    
    @IBAction func save(sender: AnyObject) {
       
        if noteTextField.text != "" {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext! //1
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note                //2
        note.name = noteTextField.text!
        note.url = audioURL
        do {
            try context.save()
        } catch _ {
        }                //5
        }
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func record(sender: AnyObject) {
        let mic = UIImage(named: "clicked_white_button.png") as UIImage!
        recordOutlet.setImage(mic, forState: .Normal)
        recordOutlet.layer.shadowOpacity = 0.9
        recordOutlet.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
        
        if audioRecorder.recording {
            audioRecorder.stop()
        }else{
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(true)
            } catch _ {
            }
            audioRecorder.record()
        }
    }
    
    @IBAction func touchDownRecord(sender: AnyObject) {
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self,
            selector: "updateAudioMeter:",
            userInfo: nil,
            repeats: true)
        timer.fire()
        
    
        recordOutlet.layer.shadowOpacity = 0.9
        recordOutlet.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        recordOutlet.layer.shadowRadius = 1.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
   
}







