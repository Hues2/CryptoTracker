//
//  LocalFileManager.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 13/08/2022.
//

import Foundation
import SwiftUI


class LocalFileManager{
    
    static let instance = LocalFileManager()
    
    private init(){}
    
    func saveImage(image: UIImage, imageName: String, folderName: String){
        
        //Before saving anything, create folder if needed
        createFolderIfNeeded(folderName: folderName)
        
        // Get path for image
        guard
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
            else {return}
        
        // Try to save image to path
        do{
            try data.write(to: url)
        } catch (let error){
            print("\n \("Error saving image:") \(imageName) --> \(error.localizedDescription) \n")
        }
    }
    
    
    func getImage(imageName: String, folderName: String) -> UIImage?{
        guard
            let url = getURLForImage(imageName: imageName, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path) else{
            return nil
        }
        
        return UIImage(contentsOfFile: url.path)
        
        
    }
    
    
    private func createFolderIfNeeded(folderName: String){
        guard let url = getURLForFolder(folderName: folderName) else {return}
        
        // If folder does not exist it creates it
        if !FileManager.default.fileExists(atPath: url.path){
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch (let error) {
                print("\n \("Error creating folder:") \(folderName) --> \(error.localizedDescription) \n")
            }
        }
    }
    
    
    private func getURLForFolder(folderName: String) -> URL?{
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        
        return url.appendingPathComponent(folderName)
    }
    
    
    
    private func getURLForImage(imageName: String, folderName: String) -> URL?{
        
        guard let folderURL = getURLForFolder(folderName: folderName) else {return nil}
        
        return folderURL.appendingPathComponent(imageName + ".png")
    }
    
}
