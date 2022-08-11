//
//  ContentView.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 11/08/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
             
            VStack(spacing: 40){
                Text("Accent Color")
                    .foregroundColor(.theme.accent)
                
                
                Text("Secondary Color")
                    .foregroundColor(.theme.secondaryText)
                
                Text("Red Color")
                    .foregroundColor(.theme.red)
                
                
                Text("Green Color")
                    .foregroundColor(.theme.green)
            }
            .font(.headline)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
