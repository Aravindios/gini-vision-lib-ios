//
//  ReviewContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class ReviewContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    fileprivate var backButton     = UIBarButtonItem()
    fileprivate var continueButton = UIBarButtonItem()

    // Images
    fileprivate var backButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationReviewBack")
    }
    fileprivate var continueButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationReviewContinue")
    }
    
    // Output
    fileprivate var imageData: Data?
    fileprivate var changes = false
    
    init(imageData: Data) {
        super.init(nibName: nil, bundle: nil)
        
        self.imageData = imageData
        
        // Configure content controller and update image data on success
        contentController = ReviewViewController(imageData, success:
            { imageData in
                self.imageData = imageData
                self.changes = true
            }, failure: { error in
                print(error)
            })
        
        // Configure title
        title = GiniConfiguration.sharedConfiguration.navigationBarReviewTitle
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure back button
        backButton = GiniBarButtonItem(
            image: backButtonImage,
            title: GiniConfiguration.sharedConfiguration.navigationBarReviewTitleBackButton,
            style: .plain,
            target: self,
            action: #selector(back)
        )
        
        // Configure continue button
        continueButton = GiniBarButtonItem(
            image: continueButtonImage,
            title: GiniConfiguration.sharedConfiguration.navigationBarReviewTitleContinueButton,
            style: .plain,
            target: self,
            action: #selector(analyse)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(continueButton, animated: false)
        
        // Add constraints
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add content to container view
        displayContent(contentController)
    }
    
    @IBAction func back() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelReview?()
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func analyse() {
        let delegate = (self.navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didReview(imageData!, withChanges: changes)
        
        // Push analysis container view controller
        navigationController?.pushViewController(AnalysisContainerViewController(imageData: imageData!), animated: true)
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
    }
    
}