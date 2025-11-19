//
//  ProfilerViewModel.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//

import Foundation
import Combine

@MainActor
class ProfilerViewModel: ObservableObject {
    @Published var status: ProfilerStatus = .idle
    
    func recordXCTrace() {
        status = .recordingXCTrace
        let pid = ProcessInfo.processInfo.processIdentifier
        
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask).first!
        
        let bundleID = Bundle.main.bundleIdentifier ?? "MyApp"
        let folderURL = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        
        try? FileManager.default.createDirectory(at: folderURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        
        // Final output file
        let outputURL = folderURL.appendingPathComponent("xctrace.trace")
        
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch {
            print("Could not remove file")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        
        process.arguments = [
            "xctrace",
            "record",
            "--attach", "\(pid)",
            "--template", "Time Profiler",
            "--time-limit", "2s",
            "--window", "100ms",
            "--output", outputURL.path
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { handle in
            if let line = String(data: handle.availableData, encoding: .utf8),
               !line.isEmpty {
                print("[xctrace] \(line)")
            }
        }
        
        do {
            try process.run()
        } catch {
            print("Failed to run xctrace: \(error)")
            return
        }
        
        process.terminationHandler = { _ in
            pipe.fileHandleForReading.readabilityHandler = nil
            print("xctrace finished with code \(process.terminationStatus)")
            print("Output written to: \(outputURL.path)")
            
            Task {
                await MainActor.run {
                    self.status = .recordingComplete
                }
                await self.exportTrace(tracePath: outputURL.path)
            }
        }
    }
    
    func exportTrace(tracePath: String) async {
        status = .startingExport
        
        let xmlTracePath = Constants.XML_TRACE_PATH
        
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "MyApp"
        let folderURL = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        
        try? FileManager.default.createDirectory(at: folderURL,
                                                 withIntermediateDirectories: true)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        
        process.arguments = [
            "xctrace",
            "export",
            "--input", tracePath,
            "--xpath", "/trace-toc/run[@number='1']/data/table[@schema='time-profile']",
            "--output", xmlTracePath
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        await withCheckedContinuation { continuation in
            
            Task.detached {
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    if let line = String(data: handle.availableData, encoding: .utf8),
                       !line.isEmpty {
                        print("[xctrace export] \(line)")
                    }
                }
                
                do {
                    try process.run()
                } catch {
                    print("Failed to run xctrace export: \(error)")
                    continuation.resume()
                    return
                }
                
                process.terminationHandler = { _ in
                    pipe.fileHandleForReading.readabilityHandler = nil
                    print("Export finished with code \(process.terminationStatus)")
                    print("Exported XML written to: \(xmlTracePath)")
                    
                    continuation.resume()
                }
            }
        }
        
        await MainActor.run {
            status = .exportComplete
        }
    }
}
