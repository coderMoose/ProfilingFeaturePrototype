//
//  ProfilerStatus.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//

import Foundation

enum ProfilerStatus {
    case idle
    case recordingXCTrace
    case recordingComplete
    case startingExport
    case exportComplete
}
