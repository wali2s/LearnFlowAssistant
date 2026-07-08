//
//  HomeView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                summarySection
                recentGoalsSection
                quickActionsSection
            }
            .padding()
            .navigationTitle("Home")
        }
    }
    
    private var headerSection: some View{
        VStack(alignment: .leading, spacing: 8){
            Text("Welcome back")
                .font(.title.bold())
            Text("Keep your learning goals and sessions in mind.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var summarySection: some View{
        VStack(alignment: .leading, spacing: 12){
            Text("Overview")
                .font(.headline)
            
            HStack{
                SummaryCard(title: "Goals", value: "\(viewModel.totalGoalCount)", color: .blue)
                SummaryCard(title: "Sessions", value: "\(viewModel.totalSessionCount)", color: .green)
            }
            
            HStack{
                SummaryCard(title: "Minutes", value: "\(viewModel.totalStudyTimeText)", color: .orange)
                SummaryCard(title: "Active", value: "\(viewModel.activeGoalCount)", color:.purple)
            }
            
        }
        
    }
    
    private var recentGoalsSection: some View{
        VStack(alignment: .leading, spacing: 12){
            Text("last goals")
                .font(.headline)
            
            if viewModel.goals.isEmpty {
                ContentUnavailableView("no goals yet", systemImage: "target",
                description: Text("Start by adding your first goal"))
            } else {
                ForEach(viewModel.recentGoals){ goal in
                    NavigationLink(destination: GoalDetailView(goal: goal)){
                        VStack(alignment: .leading, spacing: 6){
                            Text(goal.title)
                                .font(.headline)
                            Text(goal.subject)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .presentationCornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View{
        VStack(alignment: .leading, spacing: 12){
            Text("start fast")
                .font(.headline)
            
            NavigationLink(destination: SessionView()){
                Label("start a new Session", systemImage: "play.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }.buttonStyle(.plain)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
