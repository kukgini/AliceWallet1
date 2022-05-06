//
//  OnboardingFlowView.swift
//  Alice Wallet
//
//  Created by soominlee on 2022/05/06.
//

import SwiftUI

struct OnboardingFlowView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some View {
        TabView {
            WalletView(model:model)
            LedgerView(model:model)
            AgencyView(model:model)
        }
        .tabViewStyle(.page)
        .indexViewStyle(
            .page(backgroundDisplayMode:.always)
        )
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView()
    }
}
