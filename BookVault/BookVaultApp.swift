//
//  BookVaultApp.swift
//  BookVault
//
//  Created by Stuart Hedger on 15/12/2024.
//

import SwiftUI

@main
struct BookVaultApp: App {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.adaptiveBackground(colorScheme)
                    .ignoresSafeArea()
                
                SplashScreenView()
            }
        }
    }
}
