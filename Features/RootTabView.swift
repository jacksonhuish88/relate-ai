import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                   OnboardingView()
               }
               .tabItem {
                   Label("Onboarding", systemImage: "person")
               }

            MainChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }

            ConflictModeView()
                .tabItem {
                    Label("Conflict", systemImage: "exclamationmark.triangle")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    RootTabView()
}
