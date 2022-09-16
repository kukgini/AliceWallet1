//
//  OnboardingFlowView.swift
//  Alice Wallet
//
//  Created by soominlee on 2022/05/06.
//

import SwiftUI

struct OnboardingView: View {
    
    var body: some View {
        TabView {
            WalletView()
            LedgerView()
            AgencyView()
        }
        .tabViewStyle(.page)
        .indexViewStyle(
            .page(backgroundDisplayMode:.always)
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
