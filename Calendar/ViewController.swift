//
//  ViewController.swift
//  Calendar
//
//  Created by Sasibala on 09/05/24.
//

import UIKit
import EventKitUI

class ViewController: UIViewController, EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: {
//            UIApplication.shared.statusBarStyle = statusBarStyle
        })

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        show()
     }

    func show()  {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        event.title = "privacy check"
        let startdatecomponnet = DateComponents(year: 2024, month: 5)
        let startdate = Calendar.current.date(from: startdatecomponnet)
        let enddate = Calendar.current.date(byAdding: .hour, value: 2, to: startdate!)
        let controller = EKEventEditViewController()
        controller.event = event
        controller.eventStore = eventStore
        controller.editViewDelegate = self
        
        self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
        
//        eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
//                          if granted {
//                              OperationQueue.main.addOperation {
//                                  self?.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
//                              }
////                              completion?(true)
//                          } else {
//                              // Auth denied
////                              completion?(false)
//                          }
//                      })
        
////        self.present(controller, animated: true)
//        controller.modalPresentationStyle = .fullScreen
//        if let root = UIApplication.shared.keyWindow?.rootViewController {
//            root.present(controller, animated: true, completion: {
////                statusBarStyle = UIApplication.shared.statusBarStyle
//                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//            })
//        }

    }
    func presentCalendarModalToAddEvent(_ event: EKEvent, eventStore: EKEventStore, completion: ((_ success: Bool) -> Void)? = nil) {
         if #available(iOS 17, *) {
             OperationQueue.main.addOperation {
                 self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
             }
         } else {
             let authStatus = getAuthorizationStatus()
             switch authStatus {
             case .authorized:
                 OperationQueue.main.addOperation {
                     self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
                 }
                 completion?(true)
             case .notDetermined:
                 //Auth is not determined
                 //We should request access to the calendar
                 eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
                     if granted {
                         OperationQueue.main.addOperation {
                             self?.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
                         }
                         completion?(true)
                     } else {
                         // Auth denied
                         completion?(false)
                     }
                 })
             case .denied, .restricted:
                 // Auth denied or restricted
                 completion?(false)
             default:
                 completion?(false)
             }
         }
     }
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
           return EKEventStore.authorizationStatus(for: EKEntityType.event)
       }

    func presentEventCalendarDetailModal(event: EKEvent, eventStore: EKEventStore) {
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        
        if #available(iOS 13, *) {
            eventModalVC.modalPresentationStyle = .fullScreen
        }
        
        if let root = UIApplication.shared.keyWindow?.rootViewController {
            root.present(eventModalVC, animated: true, completion: {
//                statusBarStyle = UIApplication.shared.statusBarStyle
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            })
        }
    }

}

