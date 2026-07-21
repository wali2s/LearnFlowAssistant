//
//  ContentView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(AppTab.goals)

            SessionView()
                .tabItem {
                    Label("Session", systemImage: "timer")
                }
                .tag(AppTab.session)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(AppTab.stats)
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "rosette")
                }
                .tag(AppTab.achievements)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}





