//
//  ChatMessage.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


struct ChatMessage: Codable {
    let role: String
    let content: [ChatContent]
}
