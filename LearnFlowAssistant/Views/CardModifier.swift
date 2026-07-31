//
//  CardModifier.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 16.07.26.
//

import SwiftUI

import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.gray.opacity(0.12), lineWidth: 1)
            )
    }
}

struct RowStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .background(Color(.secondarySystemBackground).opacity(0.7))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(.gray.opacity(0.05), lineWidth: 1)
            )
    }
}


extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func rowStyle() -> some View {
        modifier(RowStyleModifier())
    }
}
