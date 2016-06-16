//
//  GININavigationViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GININavigationViewController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        // Edit style of navigation bar
        navigationBar.translucent = false
        navigationBar.barTintColor = GINIConfiguration.sharedConfiguration.navigationBarTintColor
        var attributes = navigationBar.titleTextAttributes ?? [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = GINIConfiguration.sharedConfiguration.navigationBarTitleColor
        navigationBar.titleTextAttributes = attributes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}