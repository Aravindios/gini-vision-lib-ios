//
//  ResultTableViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import Gini_iOS_SDK

/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
class ResultTableViewController: UITableViewController {
    
    /**
     The result dictionary from the analysis process.
     */
    var result: GINIResult!
    
    /**
     The document the results have been extracted from.
     Can be used for further processing.
     */
    var document: GINIDocument!
    
    private var sortedKeys: [String] {
        return Array(result.keys).sort(<)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If a valid document is set, send feedback on it.
        // This is just to show case how to give feedback using the Gini SDK for iOS.
        // In a real world application feedback should be triggered after the user has evaluated and eventually corrected the extractions.
        sendFeedback(forDocument: document)
    }
    
    func sendFeedback(forDocument document: GINIDocument) {
        
        /*******************************************
         * SEND FEEDBACK WITH THE GINI SDK FOR IOS *
         *******************************************/
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = (UIApplication.sharedApplication().delegate as! AppDelegate).giniSDK
        
        // 1. Get session
        sdk?.sessionManager.getSession().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if (task.error != nil) {
                return sdk?.sessionManager.logIn()
            }
            return task.result
            
        // 2. Get extractions from the document
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            return document.extractions
            
        // 3. Create and send feedback on the document
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            
            // Use `NSMutableDictionary` to work with a mutable class type which is passed by reference.
            guard let extractions = task.result as? NSMutableDictionary else {
                enum FeedbackError: ErrorType {
                    case Unknown
                }
                let error = NSError(domain: "net.gini.error.", code: FeedbackError.Unknown._code, userInfo: nil)
                return BFTask(error: error)
            }
            
            // As an example will set the BIC value statically.
            // In a real world application the user input should be used as the new value.
            // Feedback should only be send for labels which the user has seen. Unseen labels should be filtered out.

            let bicValue = "BYLADEM1001"
            let bic = extractions["bic"] as? GINIExtraction ?? GINIExtraction(name: "bic", value: "", entity: "bic", box: nil)!
            bic.value = bicValue
            extractions["bic"] = bic
            // Repeat this step for all altered fields.
            
            // Get the document task manager and send feedback by updating the document.
            let documentTaskManager = sdk?.documentTaskManager
            return documentTaskManager?.updateDocument(document)
            
        // 4. Check if feedback was send successfully (only for testing purposes)
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            return document.extractions
            
        // 5. Handle results
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                print("Error sending feedback for document with id: \(document.documentId)")
                return nil
            }
            
            let resultString = (task.result as? GINIResult)?.description ?? "n/a"
            print("Updated extractions:\n\(resultString)")
            return nil
        })
    }
}

extension ResultTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedKeys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)
        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = result[key]?.value
        cell.detailTextLabel?.text = key
        return cell
    }
}
