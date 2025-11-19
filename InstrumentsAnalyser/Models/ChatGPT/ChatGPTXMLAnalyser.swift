//
//  ChatGPTXMLAnalyser.swift
//  InstrumentsPractice
//
//  Created by Daniel on 2025-11-18.
//


import Foundation
import os

fileprivate let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "AI")

class ChatGPTXMLAnalyser {
    private let apiKey: String
    private let model: String
    
    init(model: String = "gpt-4.1") {
        // Load API key
        if let path = Bundle.main.path(forResource: "api_key", ofType: "txt") {
            do {
                apiKey = try String(contentsOfFile: path, encoding: .utf8)
            } catch{
                apiKey = "---"
                logger.error("Could not decode api_key.txt file: \(error)")
            }
        } else {
            apiKey = "---"
            logger.error("Could not find api_key.txt file")
        }
        self.model = model
    }
    
    /// Analyze an XML file by sending its contents to ChatGPT
    func analyzeXML(fileURL: URL, prompt: String) async throws -> String {
        // Convert XML file to text
        let xmlText = try String(contentsOf: fileURL, encoding: .utf8)
        
        let message = ChatMessage(
            role: "user",
            content: [
                ChatContent(
                    type: "input_text",
                    text: "Here is an XML file:\n\n\(xmlText)\n\n\(prompt)"
                )
            ]
        )
        
        let chatRequest = ChatRequest(model: model, input: [message])
        let jsonData = try JSONEncoder().encode(chatRequest)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Response
        if let httpResp = response as? HTTPURLResponse, !(200...299).contains(httpResp.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            throw NSError(domain: "ChatGPTXMLAnalyzer",
                          code: httpResp.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResp.statusCode): \(body)"])
        }
        
        print(String(data: data, encoding: .utf8) ?? "invalid utf8")
        let decoded = try JSONDecoder().decode(ChatResponseWrapper.self, from: data)

        if let firstMessage = decoded.output.first,
           let firstContent = firstMessage.content.first,
           let text = firstContent.text {
            return text
        } else {
            return "Could not answer"
        }
    }
}

