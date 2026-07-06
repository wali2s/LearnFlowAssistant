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
    
    var body: some View{
        VStack(spacing: 8){
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    SummaryCard(title: "title", value: "value", color: .gray)
}
