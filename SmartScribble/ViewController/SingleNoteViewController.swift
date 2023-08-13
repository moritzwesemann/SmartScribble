import UIKit

class SingleNoteViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!
    
    // MARK: - Properties
    var note: Note?
    var noteID: UUID?
    var noteWasDeleted = false
    
    private var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    
    private var selectedNoteIndex: Int? {
        didSet {
            if let idx = selectedNoteIndex {
                note = notes[idx]
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNoteFromStorage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateAndSaveNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Private Utility Methods
    private func loadNoteFromStorage() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
            selectedNoteIndex = notes.firstIndex(where: { $0.id == noteID })
            displayNote()
        }
    }
    
    private func displayNote() {
        titleTextField.text = note?.title
        textTextView.text = note?.text
    }
    
    private func extractHashtags(from text: String) -> [String] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { $0.hasPrefix("#") }.map { String($0.dropFirst()) }
    }
    
    private func updateAndSaveNote() {
        guard var updatedNote = note else { return }
        
        if noteWasDeleted == false {
            
            updatedNote.title = titleTextField.text ?? ""
            updatedNote.text = textTextView.text ?? ""
            updatedNote.lastEdited = Date()
            updatedNote.tags = extractHashtags(from: updatedNote.text)
            
            if let idx = selectedNoteIndex, idx < notes.count {
                notes[idx] = updatedNote
                Note.saveToFiles(notes: notes)
            }
        }
    }
    
    // MARK: - User Actions
    @IBAction func deleteNoteButton(_ sender: Any) {
        confirmNoteDeletion()
    }
    
    private func confirmNoteDeletion() {
        let alert = UIAlertController(title: "Notiz löschen", message: "Möchten Sie diese Notiz wirklich löschen?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel))
        alert.addAction(UIAlertAction(title: "Löschen", style: .destructive) { [weak self] _ in
            self?.deleteNote()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteNote() {
        if let id = noteID {
            notes.removeAll(where: { $0.id == id })
            navigationController?.popViewController(animated: true)
            noteWasDeleted = true
        }
    }
}
