//
//  PartialDocumentInfo.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/5/18.
//

import Foundation

struct PartialDocumentInfo {
    
    var documentUrl: String?
    private(set) var additionalParameters: [String: Any]?
    
    init() { }
    
    func updateAdditionalParameters(with newParameters: [String: Any]) {
        var currentParameters = additionalParameters ?? [:]
        newParameters.forEach { parameter in
            currentParameters[parameter.key] = parameter.value
        }
    }
}

extension PartialDocumentInfo {
    func toDictionary() -> [String: Any] {
        var dict = additionalParameters ?? [:]
        dict["document"] = documentUrl
       
        return dict
    }
}