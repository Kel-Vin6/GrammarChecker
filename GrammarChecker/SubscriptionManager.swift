//
//  SubscriptionManager.swift
//  GrammarChecker
//
//  Created by Kelvin Wallace on 15/07/2026.
//

import Foundation
import RevenueCat
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isSubscribed: Bool = false

    init() {
        Task {
            await refresh()
        }
    }

    func refresh() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isSubscribed = customerInfo.entitlements["pro"]?.isActive == true
        } catch {
            print("Failed to fetch subscription status:", error)
        }
    }
}
