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
        .onAppear {
            Task {
                do {
                    let fileURL = URL(fileURLWithPath: "/Users/daniel/Desktop/time_profile_data.xml")
                    
                    let analyzer = ChatGPTXMLAnalyser()
                    let promptAnswer = """
                    I have an Apple Instruments XML file from a Time Profiler trace. I want to find the hottest frames and call paths. Please do the following:
                    
                    1. Parse the XML file and locate all <row> entries in the time-profile table.
                    2. For each row, resolve the backtrace to its sequence of frames.
                    3. Count:
                       - The total number of samples.
                       - The occurrences of each frame anywhere in the backtrace (inclusive).
                       - The occurrences of the leaf (deepest) frame in each backtrace.
                       - The occurrences of exact stack paths (leaf → ... → root).
                       - The occurrences of leaf-up prefixes (partial paths).
                    4. Output the **heaviest leaf frames**, showing:
                       - Frame name
                       - Number of samples it appears as the leaf
                       - Percentage of total samples
                    5. Please provide the output in a concise, readable text table including the heaviest leaf frames and their weight. Only reply with that table (a.k.a only reply with step 5 but still do step 4, etc...)
"""
                    
                    let answer = try await analyzer.analyzeXML(
                        fileURL: fileURL,
                        prompt: promptAnswer
                    )
                    
                    print("ChatGPT answer:\n\(answer)")
                    
                } catch {
                    print("Error:", error)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
