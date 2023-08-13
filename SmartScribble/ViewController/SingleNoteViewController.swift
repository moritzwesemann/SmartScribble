import UIKit

class SingleNoteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!
    
    var note: Note?
    var noteID: UUID?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNoteFromStorage()
    }
    
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
    
    func extractHashtags(from text: String) -> [String] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { $0.hasPrefix("#") }.map { String($0.dropFirst()) }
    }
    
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
        if let index = selectedNoteIndex {
            notes.remove(at: index)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateAndSaveNote()
    }
    
    private func updateAndSaveNote() {
        guard var updatedNote = note else { return }
        
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
