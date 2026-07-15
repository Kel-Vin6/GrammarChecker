//
//  GrammarCheckerApp.swift
//  GrammarChecker
//
//  Created by Kelvin Wallace on 27/06/2026.
//

import SwiftUI
import RevenueCat


@main
struct GrammarCheckerApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var settingsStore = SettingsStore()
    @State private var showSplash: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    init() {
            Purchases.configure(withAPIKey: "appl_GZzjupwiLLpbxQtCGwgQLKmhuWh")
        }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(settingsStore)
                    .preferredColorScheme(settingsStore.colorScheme)
                    .environmentObject(subscriptionManager)

                if showOnboarding {
                    OnboardingView {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                            showOnboarding = false
                        }
                        hasCompletedOnboarding = true
                    }
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.04)),
                            removal: .opacity.combined(with: .scale(scale: 0.96))
                        )
                    )
                    .zIndex(2)
                }

                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            showSplash = false
                        }
                        if !hasCompletedOnboarding {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showOnboarding = true
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
        }
    }
}
