//
//  TranslateMeApp.swift
//  TranslateMe
//
//  Created by Sai Mannava on 4/7/24.
//

import SwiftUI
import FirebaseCore // <-- Import Firebase

@main
struct TranslateMeApp: App {

    init() { // <-- Add an init
        FirebaseApp.configure() // <-- Configure Firebase app
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
