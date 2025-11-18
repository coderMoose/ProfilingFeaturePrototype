//
//  RouterView.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


import SwiftUI

struct RouterView: View {
    @State var currentScreen: Screen = .mainScreen
    
    var body: some View {
        switch currentScreen {
        case .analyzerScreen:
            AnalyserView()
        case .mainScreen:
            MainView()
        }
    }
}

#Preview {
    RouterView()
}
