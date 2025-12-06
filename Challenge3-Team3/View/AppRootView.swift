//
//  AppRootView.swift
//  Challenge3-Team3
//
//  Created by Abeer Jeilani Osman  on 15/06/1447 AH.
//

import SwiftUI

enum AppScreen {
    case splash
    case choice
    case deafHome(name: String)
    case interpreter
}

// DELETE AppRootView - Use AppContainer instead!
// This file is no longer needed.

// If you still want to use AppRootView, here's the corrected version:

struct AppRootView: View {
    @StateObject private var appStateManager = AppStateManager()
    
    var body: some View {
        ZStack {
            switch appStateManager.appState {
            case .splash:
                splash()
                    .environmentObject(appStateManager)
                
            case .choice:
                ChoiceView()
                    .environmentObject(appStateManager)
                
            case .deafHome:
                NavigationStack {
                    DeafHome(deafName: .constant(appStateManager.deafUserName))
                        .environmentObject(appStateManager)
                }
                
            case .interpreter:
                NavigationStack {
                    InterpreterTabView()
                        .environmentObject(appStateManager)
                }
            }
        }
    }
}

// OR JUST USE AppContainer - it does the exact same thing!
// Simply replace your current root view with:
// AppContainer()

#Preview {
    AppRootView()
}
