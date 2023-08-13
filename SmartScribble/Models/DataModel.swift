// DataModel.swift
// SmartScribble
// Created by Moritz on 09.08.23.

import Foundation

struct Note: Codable {
    var id: UUID
    var title: String
    var text: String
    var tags: [String]
    var lastEdited: Date

    init(title: String, text: String, tags: [String], lastEdited: Date) {
        self.id = UUID()
        self.title = title
        self.text = text
        self.tags = tags
        self.lastEdited = lastEdited
    }
    
    static private var archiveURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("notes").appendingPathExtension("plist")
    }
    
    static func saveToFiles(notes: [Note]) {
        let encoder = PropertyListEncoder()
        do {
            let encodedNotes = try encoder.encode(notes)
            try encodedNotes.write(to: archiveURL)
        } catch {
            print("Error encoding notes: \(error)")
        }
    }
    
    static func loadFromFile() -> [Note]? {
        guard let noteData = try? Data(contentsOf: archiveURL) else {
            return nil
        }
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode([Note].self, from: noteData)
        } catch {
            print("Error decoding notes: \(error)")
            return nil
        }
    }
}
