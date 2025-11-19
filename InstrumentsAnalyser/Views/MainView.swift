//
//  MainView.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//

import SwiftUI

struct MainView: View {
    @StateObject var profilerVM = ProfilerViewModel()
    @State private var isLightbulbShown = false
    @State private var isAISummaryShown = false
    
    var body: some View {
        ZStack {
            VStack {
                topBar
                Spacer()
                mainContent
                Spacer()
            }
            .padding()
            .onChange(of: profilerVM.status, { oldStatus, newStatus in
                if newStatus == .exportComplete {
                    withAnimation(.bouncy) {
                        isLightbulbShown = true
                    }
                }
            })
            
            if isAISummaryShown {
                AnalyserView()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(.black.mix(with: .gray, by: 0.4)))
                    .padding()
                    .shadow(radius: 3)
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            if isLightbulbShown {
                Button {
                    showAISummaryView()
                } label: {
                    Image(systemName: "lightbulb.min.badge.exclamationmark.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.yellow.mix(with: .white, by: 0.2))
                        .shadow(radius: 3)
                        .padding()
                }.buttonStyle(.plain)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
    }
    
    private func startAnalysing() {
        Task {
            do {
                let fileURL = URL(fileURLWithPath: Constants.XML_TRACE_PATH)
                
                let analyzer = ChatGPTXMLAnalyser()
                let promptAnswer = """
                I have an Apple Instruments XML file from a Time Profiler trace. I want to find the hottest frames and call paths. Please do the following:
                
               Please provide the heaviest leaf frames in a concise, readable text table including the their weight and total sample time. Only reply with that table along with a quick  summary.
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
    
    private var mainContent: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                // Try to use 100% of the CPU
                Task {
                    let constant = 100000000
                    for i in 0..<constant {
                        if i % 100000 == 0 {
                            print(i)
                        }
                    }
                }
                
                profilerVM.recordXCTrace()
            } label: {
                Text("100% CPU")
            }
        }
    }
    
    private func showAISummaryView() {
        withAnimation {
            isAISummaryShown = true
        }
    }
}

#Preview {
    MainView()
}
