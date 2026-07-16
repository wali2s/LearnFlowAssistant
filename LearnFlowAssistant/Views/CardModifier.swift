//
//  CardModifier.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 16.07.26.
//

import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
