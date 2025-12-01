//
//  ChoiceViewModel.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//
import Foundation
import Combine

final class ChoiceViewModel: ObservableObject {
    // Data for the two buttons
    let options: [ChoiceOption] = [
        ChoiceOption(
            title: "I want to offer\nsupport",
            type: .offerSupport
        ),
        ChoiceOption(
            title: "I need a sign\nlanguage interpreter",
            type: .needInterpreter
        )
    ]
    
    // State for navigation or next step
    @Published var selectedChoice: ChoiceType? = nil
    
    func handleTap(on option: ChoiceOption) {
        selectedChoice = option.type
        // Add navigation or routing logic here later
        // Example: switch on option.type
    }
}
