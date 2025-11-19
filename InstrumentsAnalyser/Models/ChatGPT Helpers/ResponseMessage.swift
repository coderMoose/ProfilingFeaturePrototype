//
//  ResponseMessage.swift
//  InstrumentsAnalyser
//
//  Created by Daniel on 2025-11-18.
//


struct ResponseMessage: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ResponseContent]
}