//
//  UIApplication.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 13/08/2022.
//

import Foundation
import UIKit


extension UIApplication{
    
    func endEditing(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
