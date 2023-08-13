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
    @IBOutlet weak var saveButton: UIButton!
    
    var notes: [Note] = [] {
            didSet {
                Note.saveToFiles(notes: notes)
            }
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialer Zustand des Save-Buttons
                saveButton.isEnabled = !(noteTitleLabel.text?.isEmpty ?? true)
                
                // Beobachter hinzufügen
                noteTitleLabel.addTarget(self, action: #selector(titleDidChange), for: .editingChanged)

        
        // Laden der vorhandnen Notes
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    @objc func titleDidChange() {
            saveButton.isEnabled = !(noteTitleLabel.text?.isEmpty ?? true)
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
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let extractedTags = extractHashtags(from: noteTextView.text)
                
            //Speichern der Notiz nach verlassen des Displays
            let newNote = Note(title: noteTitleLabel.text ?? "", text: noteTextView.text, tags: extractedTags, lastEdited: Date())
            notes.append(newNote)
        
        NotificationCenter.default.post(name: NSNotification.Name("didAddNewNote"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
