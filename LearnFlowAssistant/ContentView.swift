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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)

            GoalsView(selectedTab: $selectedTab)
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}





