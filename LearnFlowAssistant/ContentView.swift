//
//  ContentView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            NavigationStack{
                HomeView()
            }
            .tabItem{
                Label("Home", systemImage: "house")
            }
            
            NavigationStack{
                GoalsView()
            }
            .tabItem {
                Label("Goals", systemImage: "target")
            }
            NavigationStack{
                SessionView()
            }
            .tabItem {
                Label("Session",systemImage: "timer")
            }
            NavigationStack{
                StartsView()
            }
            .tabItem {
                Label("Start", systemImage: "chart.bar")
            }
        }
    }
}

#Preview {
    ContentView()
}
