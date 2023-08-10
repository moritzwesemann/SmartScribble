//
//  singleNoteViewController.swift
//  SmartScribble
//
//  Created by Moritz on 10.08.23.
//

import UIKit

class SingleNoteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!
    
    var note: Note?
    var selectedNoteIndex = 0
    var noteID: UUID?
    
    var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
            
            // Finde die Notiz mit der spezifischen ID
            if let noteID = noteID {
                if let index = notes.firstIndex(where: { $0.id == noteID }) {
                    note = notes[index]
                    selectedNoteIndex = index // Speichere den Index der ausgewählten Notiz
                }
            }
            
            if let note = note {
                titleTextField.text = note.title
                textTextView.text = note.text
            }
        }
    }
    
    //Hashtags extrahieren und in Tagsarray speichern und zurückgeben
        
        func extractHashtags(from text: String) -> [String] {
            var extractedTags: [String] = []
            
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            for word in words {
                if word.hasPrefix("#") {
                    let tag = word.dropFirst() // Entferne das '#'-Zeichen
                    extractedTags.append(String(tag))
                }
            }
            
            return extractedTags
        }
        
        
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if var note = note, let editedTitle = titleTextField.text, let editedText = textTextView.text {
                // Aktualisieren Sie die Eigenschaften der Note mit den bearbeiteten Werten
                note.title = editedTitle
                note.text = editedText
                
                let extractedTags = extractHashtags(from: editedText)
                note.tags = extractedTags
                
                // Aktualisieren Sie die entsprechende Note im Array
                notes[selectedNoteIndex] = note
 
                // Speichern Sie die aktualisierten Notizen
                Note.saveToFiles(notes: notes)
            }
            
        }
        
        
    }

