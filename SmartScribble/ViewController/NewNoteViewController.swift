//  NoteViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

import UIKit


class NewNoteViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var noteTitleLabel: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Properties
    var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData()
    }
    
    // MARK: - Configuration Methods
    private func configureUI() {
        updateSaveButtonState()
        noteTitleLabel.addTarget(self, action: #selector(titleDidChange), for: .editingChanged)
    }
    
    private func loadData() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    // MARK: - Utility Methods
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
    
    // MARK: - User Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let title = noteTitleLabel.text, !title.isEmpty,
              let textContent = noteTextView.text else { return }
        
        let extractedTags = extractHashtags(from: textContent)
        let newNote = Note(title: title, text: textContent, tags: extractedTags, lastEdited: Date())
        notes.append(newNote)
        
        // Notify observers of the new note
        NotificationCenter.default.post(name: NSNotification.Name("didAddNewNote"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
}
