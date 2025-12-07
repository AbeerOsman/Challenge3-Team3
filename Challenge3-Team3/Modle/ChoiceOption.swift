//
//  ChoiceOption.swift
//  Challenge3-Team3
//
//  Created by alya Alabdulrahim on 10/06/1447 AH.
//

import Foundation

enum ChoiceType {
    case offerSupport
    case needInterpreter
}

struct ChoiceOption: Identifiable {
    let id = UUID()
    let title: String
    let type: ChoiceType
}

