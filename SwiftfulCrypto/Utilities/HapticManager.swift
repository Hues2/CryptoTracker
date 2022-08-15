//
//  HapticManager.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 15/08/2022.
//

import Foundation
import SwiftUI

class HapticManager{
    
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType){
        generator.notificationOccurred(type)
    }
    
}
