//
//  AnalyserView.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


import SwiftUI

struct AnalyserView: View {
    @State private var summary: String = ""
    @State private var isRotating: Bool = false
    
    var linearGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.blue, .indigo, .orange, .pink, .purple]), startPoint: .top, endPoint: .bottom)
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Analysing App Trace")
                Spacer()
            }
            Spacer()
            if summary == "" {
                Text("🤖")
                    .rotationEffect(isRotating ? .degrees(0) :.degrees(360))
                    .font(.custom("robotImage", size: 80))
            } else {
                Text(summary)
                    .font(.title3)
                    .foregroundStyle(linearGradient)
            }
            Spacer()
        }.onAppear {
            withAnimation(.linear.speed(0.2).repeatForever(autoreverses: false)) {
                isRotating = true
            }
            startAnalysing()
        }
    }
    
    private func startAnalysing() {
        Task {
            do {
                let fileURL = URL(fileURLWithPath: Constants.XML_TRACE_PATH)
                
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
                5. Please provide the output in a concise, readable text table including the heaviest leaf frames and their weight. Only reply with that table (a.k.a only reply with step 5 but still do step 4, etc...) along with a sentence or two summarising this for a beginner (which function is slow). 
"""
                
                let answer = try await analyzer.analyzeXML(
                    fileURL: fileURL,
                    prompt: promptAnswer
                )
                
                withAnimation {
                    summary = answer
                }
                
                print("ChatGPT answer:\n\(answer)")
                
            } catch {
                print("Error:", error)
            }
        }
    }
}

#Preview {
    AnalyserView()
}
