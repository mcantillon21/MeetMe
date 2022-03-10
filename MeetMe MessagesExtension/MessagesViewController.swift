//
//  MessagesViewController.swift
//  MeetMe MessagesExtension
//
//  Created by Molly Cantillon on 3/2/22.
//

import UIKit
import Messages
import EventKit
import EventKitUI

var dateText: String = ""
var duration: String = ""
var actualDuration: Int = 0

class MessagesViewController: MSMessagesAppViewController{
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    var actualDate: Date = Date()
    
    @IBOutlet weak var SelectButton: UIButton!
    
    private lazy var dateTimePicker: DateTimePicker = {
        let picker = DateTimePicker()
        picker.setup()
        picker.didSelectDates = {[weak self](startDate) in
            let text = Date.buildTimeRangeString(startDate: startDate)
            self?.actualDate = startDate
            self?.label.text = text
            dateText = text
        }
        return picker
    }()
    
    @IBAction func fifteen(sender: UIButton) {
        duration = "15 min"
        actualDuration = 15
    }
    @IBAction func thirty(sender: UIButton) {
        duration = "30 min"
        actualDuration = 30
    }
    @IBAction func fourtyfive(sender: UIButton) {
        duration = "45 min"
        actualDuration = 45
    }
    @IBAction func sixty(sender: UIButton) {
        duration = "60 min"
        actualDuration = 60
    }

//    @IBOutlet weak var lbl: UILabel!
//    @IBAction func slider(_ sender: UISlider) {
//        lbl.text = String(Int(sender.value))
//    }

    private var prompt: String = "Pick a time"
    @IBOutlet weak var promptLabel: UILabel!
    
    let store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.inputView = dateTimePicker.inputView
        self.label.text = dateText
        // Make sure the prompt and ice cream view are showing the correct information.
        promptLabel.text = prompt
        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTap(gesture:)));
        view.addGestureRecognizer(gestureRecognizer)
        
    }

    
    @IBAction func createEventinTheCalendar(_ sender: Any) {
        var component = DateComponents()
        component.minute = actualDuration
        createEventinTheCalendar(with: "Sync", forDate: actualDate, toDate: Calendar.current.date(byAdding: component, to: actualDate)!)
        
        //create alert to confirm
        let alert = UIAlertController(title: "Added to Calendar", message: "The event has been added to your calendar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    func createEventinTheCalendar(with title:String, forDate eventStartDate:Date, toDate eventEndDate:Date) {
           
           store.requestAccess(to: .event) { (success, error) in
               if  error == nil {
                   let event = EKEvent.init(eventStore: self.store)
                   event.title = title
                   event.calendar = self.store.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
                   event.startDate = eventStartDate
                   event.endDate = eventEndDate
                   
                   let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                   event.addAlarm(alarm)
                   
                   do {
                       try self.store.save(event, span: .thisEvent)
                       //event created successfullt to default calendar
                   } catch let error as NSError {
                       print("failed to save event with error : \(error)")
                   }

               } else {
                   //we have error in getting access to device calnedar
                   print("error = \(String(describing: error?.localizedDescription))")
               }
           }
       }

    
    @objc func backgroundTap(gesture : UITapGestureRecognizer) {
        textField.resignFirstResponder() // or view.endEditing(true)
    }
    
    @IBAction func didPress(button sender: AnyObject) {
        if let image = createImageForMessage(), let conversation = activeConversation {
            let layout = MSMessageTemplateLayout()
            layout.image = image
            layout.caption = "$\(conversation.localParticipantIdentifier.uuidString) wants to sync"
//            layout.caption = "Be there or be square!"
             
            let message = MSMessage()
            message.layout = layout
            message.url = URL(string: "emptyURL")
            
            conversation.insert(message) { error in
                print("ERRRRRRRRRRR: \(error)")
            }
        }
    }
    
    func createImageForMessage() -> UIImage? {
        let background = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        background.backgroundColor = .white
         
        let label = UILabel(frame: CGRect(x: 60, y: 60, width: 180, height: 180))
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.backgroundColor = .white
        label.textColor = .red
        let result: String = dateText
                label.numberOfLines = 0
                label.text = result + "\n" + duration
                label.textAlignment = .center
                label.layer.cornerRadius = label.frame.size.width/2.0
                label.clipsToBounds = true
                 
                background.addSubview(label)
                background.frame.origin = CGPoint(x: view.frame.size.width, y: view.frame.size.height)
                view.addSubview(background)
                 
                UIGraphicsBeginImageContextWithOptions(background.frame.size, false, UIScreen.main.scale)
                background.drawHierarchy(in: background.bounds, afterScreenUpdates: true)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                 
                background.removeFromSuperview()
                 
                return image
    }
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        
//        if presentationStyle == .expanded {
//            SelectButton.isHidden = true
//            let controller: UIViewController = storyboard!.instantiateViewController(withIdentifier: "MeetMeViewController") as! MessagesViewController
//            addChild(controller)
//            view.addSubview(controller.view)
//        } else {
        let controller: UIViewController = storyboard!.instantiateViewController(withIdentifier: "MeetMeViewController") as! MessagesViewController
        addChild(controller)
        view.addSubview(controller.view)
//        }
    }

}
