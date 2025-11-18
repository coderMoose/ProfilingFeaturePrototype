//
//  MainView.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                let constant = 100000000
                for i in 0..<constant {
                    if i % 1000 == 0 {
                        print(i)
                    }
                }
            } label: {
                Text("100% CPU")
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
}
