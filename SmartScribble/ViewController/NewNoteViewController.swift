//
//  NoteViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class NewNoteViewController: UIViewController {

    @IBOutlet weak var noteTitleLabel: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    var notes: [Note] = [] {
            didSet {
                Note.saveToFiles(notes: notes)
            }
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Laden der vorhandnen Notes
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
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
        
        let extractedTags = extractHashtags(from: noteTextView.text)
        
        //Speichern der Notiz nach verlassen des Displays
        let newNote = Note(title: noteTitleLabel.text ?? "", text: noteTextView.text, tags: extractedTags, lastEdited: Date())
                notes.append(newNote)
        }
    
    //hier müssen die Tags noch hinzugefügt werden
    
    

}
