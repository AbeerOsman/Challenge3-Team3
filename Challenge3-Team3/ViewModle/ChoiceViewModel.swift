//
//  ChoiceViewModel.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//
import Foundation
import Combine

final class ChoiceViewModel: ObservableObject {
    @Published var selectedChoice: ChoiceType?

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

    func handleTap(on option: ChoiceOption) {
        selectedChoice = option.type
    }
}
