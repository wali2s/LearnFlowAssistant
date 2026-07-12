//
//  HomeView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            ScrollView{
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
                                .foregroundStyle(.blue.opacity(0.8))
                               
                            Text(goal.subject)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .background(Color(.systemGray6))
                        .presentationCornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View{
        VStack(alignment: .leading, spacing: 12){
            Text("Quick Actions")
                .font(.headline)
            
            Button {
                selectedTab = .goals
            }label: {
                Label("Add or edit goals", systemImage: "target")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.7))
                    .foregroundStyle(.white)
                    .cornerRadius(15)
                
            }
            .padding(.horizontal)

            
            
            Button {
                selectedTab = .session
            }label: {
                Label (!isSessionRunning ?"Start a new session" : "Resume current session", systemImage: isSessionRunning ? "pause.circle.fill" :"play.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(isSessionRunning ? Color.orange.opacity(0.7) : Color.green.opacity(0.7))
                    .cornerRadius(15)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .disabled(!canStartSession)
            
            if isSessionRunning {
                Text("A learning goal is currently in progress.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else if !canStartSession {
                Text("You have no goals to work on.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            Button {
                selectedTab = .stats
            } label: {
                Label("Open statistics", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(15)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            
                
            }
        }
    
    var isSessionRunning: Bool {
        viewModel.activeSessionStart != nil
    }
    
    var canStartSession: Bool {
        !viewModel.goals.isEmpty
    }
    }


#Preview {
    HomeView(selectedTab: .constant(.home))
           .environmentObject(AppViewModel())
}
