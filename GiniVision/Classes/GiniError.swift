//
//  GiniError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

/**
 Errors thrown on the camera screen or during camera initialization.
 */
@objc public enum CameraError: Int, Error {
    
    /// Unknown error during camera use.
    case unknown = 0
    
    /// Camera can not be loaded because the user has denied authorization in the past.
    case notAuthorizedToUseDevice
    
    /// No valid input device could be found for capturing.
    case noInputDevice
    
    /// Capturing could not be completed.
    case captureFailed
    
}

/**
 Errors thrown on the review screen.
 */
@objc public enum ReviewError: Int, Error {
    
    /// Unknown error during review.
    case unknown = 0
    
}

/**
 Errors thrown when picking a file (image or pdf).
 */
@objc public enum PickerError: Int, Error {
    
    /// Unknown error during review.
    case unknown = 0
    
    /// Exceeded max file size
    case exceededMaxFileSize
    
    /// Image format not valid
    case imageFormatNotValid
    
    /// File format not valid
    case fileFormatNotValid
    
    /// Exceeded max file size
    case pdfPageLengthExceeded
    
}

