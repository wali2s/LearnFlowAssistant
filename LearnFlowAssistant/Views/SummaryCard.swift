//
//  SummaryCard.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 07.07.26.
//

import SwiftUI

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .summaryCardStyle()
    }
}

struct SummaryCardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.gray.opacity(0.10), lineWidth: 1)
            )
    }
}

extension View {
    func summaryCardStyle() -> some View {
        modifier(SummaryCardStyleModifier())
    }
}

#Preview {
    SummaryCard(title: "title", value: "value", color: .gray)
}
