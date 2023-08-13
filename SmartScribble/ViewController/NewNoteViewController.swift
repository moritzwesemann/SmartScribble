//  NoteViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

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
        
        updateSaveButtonState()
        
        noteTitleLabel.addTarget(self, action: #selector(titleDidChange), for: .editingChanged)

        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    @objc func titleDidChange() {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        saveButton.isEnabled = !(noteTitleLabel.text?.isEmpty ?? true)
    }
    
    func extractHashtags(from text: String) -> [String] {
        var extractedTags: [String] = []
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if word.hasPrefix("#") {
                let tag = word.dropFirst()
                extractedTags.append(String(tag))
            }
        }
        
        return extractedTags
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let title = noteTitleLabel.text, !title.isEmpty,
              let textContent = noteTextView.text else { return }
        
        let extractedTags = extractHashtags(from: textContent)
        let newNote = Note(title: title, text: textContent, tags: extractedTags, lastEdited: Date())
        notes.append(newNote)
        
        NotificationCenter.default.post(name: NSNotification.Name("didAddNewNote"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
