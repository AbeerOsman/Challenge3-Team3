//
//  SplashViewModel.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

import Foundation
import Combine

final class SplashViewModel: ObservableObject {
    @Published var isActive = false

    init() {
        start()
    }

    private func start() {
        // show splash for 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isActive = true
        }
    }
}
