//
//  ChatResponseWrapper.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


struct ChatResponseWrapper: Codable {
    let id: String
    let object: String
    let output: [ResponseMessage]
}
