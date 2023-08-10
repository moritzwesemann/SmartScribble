//
//  DataModel.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import Foundation

struct Note: Codable {
    var title: String
    var text: String
    var tags: [String]
    var lastEdited: Date
    
    static var archiveURL: URL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first!
        let archiveURL = documentsURL.appendingPathComponent("notes").appendingPathExtension("plist")
        return archiveURL
    }
    
    static func saveToFiles(notes: [Note]){
        let encoder = PropertyListEncoder()
        do {
            let encodedNotes = try encoder.encode(notes)
            try encodedNotes.write(to: Note.archiveURL)
        } catch {
            print("Error encoding notes: \(error)")
        }
    }
    static func loadFromFile() -> [Note]? {
        guard let noteData = try? Data(contentsOf: Note.archiveURL) else {
            return nil
        }
        do {
                   let decoder = PropertyListDecoder()
                   let decodedNotes = try decoder.decode([Note].self, from: noteData)
                   
                   return decodedNotes
               } catch {
                   print("Error decoding notes: \(error)")
                   return nil
               }
    }
}
