//
//  DocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

final class CompositeDocumentService: DocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var isAnalyzing = false
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfo = partialDocuments.map { $0.value }
        self.fetchExtractions(for: partialDocumentsInfo, completion: completion)
    }
    
    func cancelAnalysis() {
        if let compositeDocument = compositeDocument {
            deleteCompositeDocument(withId: compositeDocument.documentId)
        }
        
        compositeDocument = nil
        isAnalyzing = false
    }
    
    func remove(document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partialDocumentId = partialDocuments[document.id]?
                .documentUrl?
                .components(separatedBy: "/")
                .last {
                deletePartialDocument(withId: partialDocumentId)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    func update(parameters: [String: Any], for document: GiniVisionDocument) {
        self.partialDocuments[document.id]?.updateAdditionalParameters(with: parameters)
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        self.partialDocuments[document.id] = PartialDocumentInfo()
        
        createDocument(from: document, fileName: "", cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.documentUrl = createdDocument.links.document
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}