//
//  GINIMultipageReviewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINIMultipageReviewControllerTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration.sharedConfiguration
    lazy var multipageReviewViewController: MultipageReviewController = {
        let vc = MultipageReviewController(imageDocuments: self.imageDocuments,
                                           giniConfiguration: self.giniConfiguration)
        _ = vc.view
        return vc
    }()
    
    lazy var imageDocuments: [GiniImageDocument] = [
        self.loadImageDocument(withName: "invoice"),
        self.loadImageDocument(withName: "invoice2"),
        self.loadImageDocument(withName: "invoice3")
    ]
    
    func testCollectionsItemsCount() {
        XCTAssertEqual(multipageReviewViewController.mainCollection.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
        
        XCTAssertEqual(multipageReviewViewController.pagesCollection.numberOfItems(inSection: 0), 3,
                       "pages collection items count should be 3")
    }
    
    func testMainCollectionCellContent() {
        let firstCell = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewMainCollectionCell
        let secondCell = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewMainCollectionCell
        let thirdCell = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewMainCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")

    }
    
    func testMainCollectionCellContentMode() {
        let firstCell = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewMainCollectionCell
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFit,
                       "Main collection cells image content mode should match the one passed in the initializer")
    }
    
    func testMainCollectionCellSize() {
        multipageReviewViewController.view.setNeedsLayout()
        multipageReviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                         layout: multipageReviewViewController.mainCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        XCTAssertEqual(cellSize, multipageReviewViewController.mainCollection.frame.size,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionInsets() {
        let collectionInsets = multipageReviewViewController.collectionView(multipageReviewViewController.mainCollection,
                                                 layout: multipageReviewViewController.mainCollection.collectionViewLayout,
                                                 insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, .zero,
                       "Main collection insets should be zero")
    }
    
    func testPagesCollectionCellContent() {
        let firstCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        let secondCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewPagesCollectionCell
        let thirdCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewPagesCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.pageIndicatorLabel.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.pageIndicatorLabel.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.pageIndicatorLabel.text, "3",
                       "Third cell indicator should match its position")
    }
    
    func testPagesCollectionCellContentMode() {
        let firstCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFill,
                       "Pages collection cells image content mode should match the one passed in the initializer")
    }
    
    func testPagesCollectionCellSize() {
        multipageReviewViewController.view.setNeedsLayout()
        multipageReviewViewController.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                         layout: multipageReviewViewController.pagesCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        let size = MultipageReviewPagesCollectionCell.size
        
        XCTAssertEqual(cellSize, size,
                       "Pages collection cells should have the value declared in the class")
    }
    
    func testPagesCollectionInsets() {
        let collectionInsets = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                                 layout: multipageReviewViewController.pagesCollection.collectionViewLayout,
                                                 insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, multipageReviewViewController.pagesCollectionInsets,
                       "Main collection insets should be zero")
    }
    
    func testToolBarItemsOnInitialization() {
        guard let items = self.multipageReviewViewController.toolBar.items else {
            assertionFailure("MultipageReviewController toolbar items are nil")
            return
        }
        XCTAssertEqual(items[0], self.multipageReviewViewController.rotateButton,
                       "First toolbar item should be the rotateButton")
        XCTAssertEqual(items[2], self.multipageReviewViewController.reorderButton,
                       "Third toolbar item should be the reorderButton")
        XCTAssertEqual(items[4], self.multipageReviewViewController.deleteButton,
                       "Fifth toolbar item should be the deleteButton")
    }
    
    func testToolBarAndPagesCollectionContainerColors() {
        XCTAssertEqual(multipageReviewViewController.toolBar.barTintColor, multipageReviewViewController.pagesCollectionContainer.backgroundColor,
                       "toolbar and pages collection container background colors should match")
    }
    
    func testDatasourceOnDelete() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments, giniConfiguration: giniConfiguration)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        (vc.deleteButton.customView as? UIButton)?.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 2,
                       "main collection items count should be 2")
        XCTAssertEqual(vc.pagesCollection.numberOfItems(inSection: 0), 2,
                       "pages collection items count should be 2")
    }
    
    func testCellReloadedOnReordering() {
        let expect = expectation(description: "Delayed reloading on reordering has finished")
        let currentIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 2, section: 0)
        var updatedImageDocument: [GiniImageDocument] = []
        
        multipageReviewViewController.didUpdateDocuments = { updatedDocuments in
            updatedImageDocument = updatedDocuments
            expect.fulfill()
        }
        
        multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection, moveItemAt: currentIndexPath, to: destinationIndexPath)
        
        wait(for: [expect], timeout: 1)
        let firstCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        let secondCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewPagesCollectionCell
        let thirdCell = multipageReviewViewController.collectionView(multipageReviewViewController.pagesCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewPagesCollectionCell
        
        XCTAssertEqual(firstCell?.documentImage.image, updatedImageDocument[0].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.pageIndicatorLabel.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.documentImage.image, updatedImageDocument[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.pageIndicatorLabel.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.documentImage.image, updatedImageDocument[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.pageIndicatorLabel.text, "3",
                       "Third cell indicator should match its position")
        
    }
    
    func testDeleteButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true
        
        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertFalse(multipageReviewViewController.deleteButton.isEnabled,
                       "delete button should be disabled when tooltip is shown")
        
    }
    
    func testDeleteButtonEnabledWhenToolTipIsNotShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertTrue(multipageReviewViewController.deleteButton.isEnabled,
                       "delete button should be disabled when tooltip is shown")
        
    }
    
    func testRotateButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true

        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)

        XCTAssertFalse(multipageReviewViewController.rotateButton.isEnabled,
                       "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testRotateButtonEnabledWhenToolTipIsNotShown() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        multipageReviewViewController.viewDidAppear(false)
        
        XCTAssertTrue(multipageReviewViewController.rotateButton.isEnabled,
                       "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testToolTipShouldAppearTheFirstTime() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = true
        
        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        XCTAssertNotNil(multipageReviewViewController.toolTipView,
                     "rotate button should be disabled when tooltip is shown")
        
    }
    
    func testToolTipShouldNotAppearWhenItWasShownBefore() {
        ToolTipView.shouldShowReorderPagesButtonToolTip = false
        
        multipageReviewViewController = MultipageReviewController(imageDocuments: imageDocuments,
                                                                  giniConfiguration: giniConfiguration)
        _ = multipageReviewViewController.view
        
        XCTAssertNil(multipageReviewViewController.toolTipView,
                     "rotate button should be disabled when tooltip is shown")
        
    }
}
