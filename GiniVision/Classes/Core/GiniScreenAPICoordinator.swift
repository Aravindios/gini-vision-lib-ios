//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    var rootViewController: UIViewController { get }
}

final class GiniScreenAPICoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return screenAPINavigationController
    }
    
    fileprivate(set) lazy var screenAPINavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.delegate = self
        navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        return navigationController
    }()
    
    // Screens
    var analysisViewController: AnalysisViewController?
    var cameraViewController: CameraViewController?
    var imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController?
    var reviewViewController: ReviewViewController?
    lazy var multiPageReviewViewController: MultipageReviewViewController = {
        if let type = self.documentRequests.type, type != .image {
            assertionFailure("The MultipageReviewViewController can only handle image documents.")
        }
        let multiPageReviewViewController =
            self.createMultipageReviewScreenContainer(with: self.documentRequests)
        return multiPageReviewViewController
    }()
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator()
    }()
    
    // Properties
    fileprivate(set) var giniConfiguration: GiniConfiguration
    fileprivate(set) var documentRequests: [DocumentRequest] = []
    fileprivate let multiPageTransition = MultipageReviewTransitionAnimator()
    weak var visionDelegate: GiniVisionDelegate?
    // Resources
    fileprivate(set) lazy var backButtonResource =
        PreferredButtonResource(image: "navigationReviewBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the back button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleBackButton)
    fileprivate(set) lazy var cancelButtonResource =
        PreferredButtonResource(image: "navigationAnalysisBack",
                                title: "ginivision.navigationbar.analysis.back",
                                comment: "Button title in the navigation bar for" +
            "the back button on the analysis screen",
                                configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate(set) lazy var closeButtonResource =
        PreferredButtonResource(image: "navigationCameraClose",
                                title: "ginivision.navigationbar.camera.close",
                                comment: "Button title in the navigation bar for the close button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate(set) lazy var helpButtonResource =
        PreferredButtonResource(image: "navigationCameraHelp",
                                title: "ginivision.navigationbar.camera.help",
                                comment: "Button title in the navigation bar for the help button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
    fileprivate(set) lazy var nextButtonResource =
        PreferredButtonResource(image: "navigationReviewContinue",
                                title: "ginivision.navigationbar.review.continue",
                                comment: "Button title in the navigation bar for " +
            "the continue button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleContinueButton)
    
    init(withDelegate delegate: GiniVisionDelegate?,
         giniConfiguration: GiniConfiguration) {
        self.visionDelegate = delegate
        self.giniConfiguration = giniConfiguration
        super.init()
    }
    
    func start(withDocuments documents: [GiniVisionDocument]?) -> UIViewController {
        let viewControllers: [UIViewController]
        if let documents = documents, !documents.isEmpty {
            if documents.count > 1, !giniConfiguration.multipageEnabled {
                fatalError("You are trying to import several files from other app when the Multipage feature is not " +
                    "enabled. To enable it just set `multipageEnabled` to `true` in the `GiniConfiguration`")
            }
            
            if !documents.containsDifferentTypes {
                let documentRequests: [DocumentRequest] = documents.map { DocumentRequest(value: $0) }
                self.addToDocuments(new: documentRequests)
                if !giniConfiguration.openWithEnabled {
                    fatalError("You are trying to import a file from other app when the Open With feature is not " +
                        "enabled. To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
                }
                viewControllers = initialViewControllers(with: documentRequests)
                
            } else {
                fatalError("You are trying to import both PDF and images at the same time. " +
                    "For now it is only possible to import either images or one PDF")
            }
        } else {
            self.cameraViewController = self.createCameraViewController()
            viewControllers = [self.cameraViewController!]
        }
        
        self.screenAPINavigationController.setViewControllers(viewControllers, animated: false)
        return ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                             parent: self)
    }
    
    private func initialViewControllers(with documentRequests: [DocumentRequest]) -> [UIViewController] {
        if documentRequests.type == .image {
            if giniConfiguration.multipageEnabled {
                self.cameraViewController = self.createCameraViewController()
                if let lastImage = documents.last?.value.previewImage {
                    self.cameraViewController?.updateCapturedImagesStack(to: .filled(count: documents.count,
                                                                                     lastImage: lastImage))
                }
                self.multiPageReviewViewController =
                    createMultipageReviewScreenContainer(with: documentRequests)
                
                return [self.cameraViewController!, self.multiPageReviewViewController]
            } else {
                self.cameraViewController = self.createCameraViewController()
                self.reviewViewController = self.createReviewScreen(withDocument: documentRequests[0].document)
                return [self.cameraViewController!, self.reviewViewController!]
            }
        } else {
            self.analysisViewController = self.createAnalysisScreen(withDocument: documentRequests[0].document)
            return [self.analysisViewController!]
        }
    }
}

// MARK: - Session documents

extension GiniScreenAPICoordinator {
    func addToDocuments(new documentRequests: [DocumentRequest]) {
        self.documentRequests.append(contentsOf: documentRequests)
        
        if giniConfiguration.multipageEnabled, documentRequests.type == .image {
            refreshMultipageReview(with: documentRequests)
        }
    }
    
    func removeFromDocuments(document: GiniVisionDocument) {
        documentRequests.remove(document)
    }
    
    func updateValueInDocuments(for document: GiniVisionDocument) {
        if let index = documentRequests.index(of: document) {
            documentRequests[index].document = document
        }
    }
    
    func updateUploadStatusInDocuments(for document: GiniVisionDocument, to uploaded: Bool) {
        if let index = documentRequests.index(of: document) {
            documentRequests[index].isUploaded = uploaded
        }
    }
    
    func updateErrorInDocuments(for document: GiniVisionDocument, to error: Error) {
        if let index = documentRequests.index(of: document) {
            documentRequests[index].error = error
        }
    }
    
    func replaceDocuments(with documentRequests: [DocumentRequest]) {
        self.documentRequests = documentRequests
    }
    
    func clearDocuments() {
        documentRequests.removeAll()
    }
}

// MARK: - Button actions

extension GiniScreenAPICoordinator {
    
    @objc func back() {
        if self.screenAPINavigationController.viewControllers.count == 1 {
            self.closeScreenApi()
        } else {
            self.screenAPINavigationController.popViewController(animated: true)
        }
    }
    
    @objc func closeScreenApi() {
        self.visionDelegate?.didCancelCapturing()
    }
    
    @objc func showHelpMenuScreen() {
        self.screenAPINavigationController.pushViewController(HelpMenuViewController(), animated: true)
    }
    
    @objc func showAnalysisScreen() {
        visionDelegate?.didReview(documents: documentRequests.map { $0.document })
        
        self.analysisViewController = createAnalysisScreen(withDocument: documentRequests[0].document)
        self.screenAPINavigationController.pushViewController(analysisViewController!, animated: true)
    }
    
    @objc func backToCamera() {
        if let cameraViewController = cameraViewController {
            screenAPINavigationController.popToViewController(cameraViewController, animated: true)
        }
    }
}

// MARK: - Navigation delegate

extension GiniScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC == analysisViewController && operation == .pop {
            analysisViewController = nil
            visionDelegate?.didCancelAnalysis()
        }
        if fromVC == reviewViewController && toVC == cameraViewController {
            // This can only happen when not using multipage
            reviewViewController = nil
            if let firstDocument = documentRequests.first?.document {
                if let didCancelReviewForDocument = visionDelegate?.didCancelReview(for:) {
                    didCancelReviewForDocument(firstDocument)
                } else {
                    fatalError("GiniVisionDelegate.didCancelReview(for document: GiniVisionDocument)" +
                        "should be implemented")
                }
                
                clearDocuments()
            }
        }
        
        let isFromCameraToMultipage = (toVC == multiPageReviewViewController && fromVC == cameraViewController)
        let isFromMultipageToCamera = (fromVC == multiPageReviewViewController && toVC == cameraViewController)
        
        if isFromCameraToMultipage || isFromMultipageToCamera {
            return multipageTransition(operation: operation, from: fromVC, to: toVC)
        }
        
        return nil
    }
    
    private func multipageTransition(operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let reviewImagesButtonCenter = cameraViewController?.capturedImagesStackView,
            let buttonFradme = cameraViewController?
                .capturedImagesStackView
                .convert(reviewImagesButtonCenter.frame,
                         to: screenAPINavigationController.view) else {
                            return nil
        }
        
        multiPageTransition.originFrame = reviewImagesButtonCenter.absoluteThumbnailFrame(from: screenAPINavigationController.view)
        multiPageTransition.operation = operation
        
        if let multipageVC = fromVC as? MultipageReviewViewController, let cameraVC = toVC as? CameraViewController {
            if let (image, size) = multipageVC.visibleImage(in: multipageVC.mainCollection) {
                multiPageTransition.popImage = image
                multiPageTransition.popImageFrame = size
                cameraVC.updateCapturedImagesStack(to: .filled(count: sessionDocuments.count, lastImage: image))
            } else {
                cameraVC.updateCapturedImagesStack(to: .empty)
                return nil
            }
        }
        
        return multiPageTransition
    }
}
