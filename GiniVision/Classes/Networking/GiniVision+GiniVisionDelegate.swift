//
//  GiniVision+GiniVisionDelegate.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation

extension GiniVision {
    public class func viewController(withClient client: Client,
                                     importedDocument: GiniVisionDocument? = nil,
                                     giniConfiguration: GiniConfiguration,
                                     resultsDelegate: GiniVisionResultsDelegate) -> UIViewController {
        print("Gini Vision Library for iOS (\(GiniVision.versionString)) / Client id: \(client.clientId)")

        GiniVision.setConfiguration(giniConfiguration)
        let screenCoordinator = GiniScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: giniConfiguration)
        return screenCoordinator.start(withDocument: importedDocument)
    }
    
}