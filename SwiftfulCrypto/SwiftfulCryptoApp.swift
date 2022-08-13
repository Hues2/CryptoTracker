//
//  SwiftfulCryptoApp.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 11/08/2022.
//

import SwiftUI

@main
struct SwiftfulCryptoApp: App {
    
    @StateObject private var vm = HomeViewModel()
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .navigationBarHidden(true)
            }
            .environmentObject(vm)
        }
    }
}
