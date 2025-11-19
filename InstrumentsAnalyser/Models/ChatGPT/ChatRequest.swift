//
//  ChatRequest.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


struct ChatRequest: Codable {
    let model: String
    let input: [ChatMessage]
}