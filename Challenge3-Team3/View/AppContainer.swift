//
//  AppContainer.swift
//  Challenge3-Team3
//
//  Created by Abeer Jeilani Osman  on 15/06/1447 AH.
//

import SwiftUI
import Combine

final class AppStateManager: ObservableObject {
    @Published var appState: AppNavigationState = .splash
    @Published var userRole: String? = nil
    @Published var deafUserName: String = ""
    
    private let roleStorageKey = "userRole"
    private let deafNameStorageKey = "deafUserName"

    init() {
        // Load saved state from UserDefaults
        if let savedRole = UserDefaults.standard.string(forKey: roleStorageKey) {
            self.userRole = savedRole
        }
        
        if let savedName = UserDefaults.standard.string(forKey: deafNameStorageKey) {
            self.deafUserName = savedName
        }
        
        // Always start with splash
        self.appState = .splash
    }

    func moveToChoiceView() {
        // First time user or no role saved
        self.appState = .choice
    }

    func moveToNextScreen() {
        // Called after splash animation completes
        if let role = userRole {
            // User has made a choice before
            if role == "requester" {
                self.appState = .deafHome
            } else if role == "interpreter" {
                self.appState = .interpreter
            }
        } else {
            // First time user
            self.appState = .choice
        }
    }

    func setUserRole(_ role: String, deafName: String? = nil) {
        self.userRole = role
        UserDefaults.standard.set(role, forKey: roleStorageKey)
        
        if let name = deafName {
            self.deafUserName = name
            UserDefaults.standard.set(name, forKey: deafNameStorageKey)
        }
        
        // Update app state based on role
        if role == "requester" {
            self.appState = .deafHome
        } else if role == "interpreter" {
            self.appState = .interpreter
        }
    }

    func logout() {
        userRole = nil
        deafUserName = ""
        appState = .splash
        UserDefaults.standard.removeObject(forKey: roleStorageKey)
        UserDefaults.standard.removeObject(forKey: deafNameStorageKey)
    }
}

enum AppNavigationState {
    case splash
    case choice
    case deafHome
    case interpreter
}

// MARK: - Main App Container
struct AppContainer: View {
    @StateObject private var appStateManager = AppStateManager()
    
    var body: some View {
        ZStack {
            switch appStateManager.appState {
            case .splash:
                splash()
                    .environmentObject(appStateManager)
                    .transition(.opacity)
                
            case .choice:
                ChoiceView()
                    .environmentObject(appStateManager)
                    .transition(.opacity)
                
            case .deafHome:
                NavigationStack {
                    DeafHome(deafName: .constant(appStateManager.deafUserName))
                        .environmentObject(appStateManager)
                }
                .transition(.opacity)
                
            case .interpreter:
                NavigationStack {
                    InterpreterTabView()
                        .environmentObject(appStateManager)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appStateManager.appState)
    }
}
#Preview {
    AppContainer()
}
