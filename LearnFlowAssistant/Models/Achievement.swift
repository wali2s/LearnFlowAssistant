//
//  Achievement.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 21.07.26.
//

import Foundation
struct Achievement: Identifiable {
    
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}
