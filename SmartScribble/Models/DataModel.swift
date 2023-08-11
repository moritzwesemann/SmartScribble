//
//  DataModel.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import Foundation

struct Note: Codable {
    var id: UUID
    var title: String
    var text: String
    var tags: [String]
    var lastEdited: Date
    
    //Konstruktor
    init(title: String, text: String, tags: [String], lastEdited: Date) {
        self.id = UUID() // Generiert automatisch eine eindeutige ID
        self.title = title
        self.text = text
        self.tags = tags
        self.lastEdited = lastEdited
    }
    
    //Filepath zum anspeichern der Daten
    static var archiveURL: URL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask).first!
        let archiveURL = documentsURL.appendingPathComponent("notes").appendingPathExtension("plist")
        return archiveURL
    }
    
    //Speichern der Notes
    static func saveToFiles(notes: [Note]){
        let encoder = PropertyListEncoder()
        do {
            let encodedNotes = try encoder.encode(notes)
            try encodedNotes.write(to: Note.archiveURL)
        } catch {
            print("Error encoding notes: \(error)")
        }
    }
    
    //Laden der Notes
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
