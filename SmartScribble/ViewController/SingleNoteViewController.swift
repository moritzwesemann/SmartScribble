import UIKit
import OpenAI

class SingleNoteViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!
    
    // MARK: - Properties
    var note: Note?
    var noteID: UUID?
    var noteWasDeleted = false
    
    //Ki properties
    var openAI:OpenAI?
    var uniqueTags: Set<String> = []
    var tagsArray: [String] = []
    var notesWithoutTags: Int = 0
    
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
        configureDesign()
        openAI = OpenAI(apiToken: getApiKey())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateAndSaveNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - API Key
    func getApiKey() -> String {
        if let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            return dict["API_KEY"] as! String
        }
        return "Error"
    }
    
 
    private func updateTagsArray() {
        uniqueTags.removeAll()
        notesWithoutTags = 0
        
        for note in notes {
            if note.tags.isEmpty {
                notesWithoutTags += 1
            } else {
                uniqueTags.formUnion(note.tags)
            }
        }
        
        tagsArray = Array(uniqueTags)
        tagsArray.sort()
        
        // Falls es Notizen ohne Tags gibt, den "Ohne Label"-Eintrag am Anfang des Arrays hinzufügen
        if notesWithoutTags > 0 {
            tagsArray.insert("Sonstiges", at: 0)
        }
    }
    
    // MARK: - Design Configuration
    private func configureDesign() {
        // Custom gray color
        let customGray = UIColor(white: 0.95, alpha: 1.0)

        // For noteView
        noteView.backgroundColor = customGray
        noteView.layer.cornerRadius = 5.0
        noteView.clipsToBounds = true
        noteView.layer.masksToBounds = false // Da wir einen Schatten verwenden, sollten wir dies auf false setzen
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
    
    @IBAction func kiButtonPressed(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty ,
                      let textContent = textTextView.text else { return }
                
                note = Note(title: title, text: textContent, tags: extractHashtags(from: textContent), lastEdited: Date())
                
                var noteString = "Title: \(note!.title)\nText: \(note!.text)\nTags: \(note!.tags.joined(separator: ", "))"
                
                let promptString = """
                Hier ist eine Notiz,die in einer prägnanten und gut strukturierten Form gebracht werden soll. Der Titel soll kurz und beschreibend sein. Der Inhalt soll weniger aus Fließtext und mehr aus Abschnitten bestehen die mit Absätzen separiert sind. Die jeweiligen Abschnitte sollen die Hauptthemen abdecken und z.B. Stichpunktlisten der Aufgaben erstellen und Informationen zusammenfassen. Weiterhin soll ein relevanter Hashtag hinzugefügt werden (bevorzugt aus der Liste: \(uniqueTags)). Achte darauf, dass ich die Anwtwort mithlfe der JSONSerialization Methode in JSON übersetzen kann:
                {
                  "Titel": "DEIN KORRIGIERTER TITEL",
                  "Inhalt": "DEIN KORRIGIERTER INHALT",
                  "Hashtag": "#DEIN_HASHTAG"
                }
                Text:
                \(noteString)
                """
                
                Task{
                    do {
                        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: promptString)])
                        let result = try await openAI!.chats(query: query)
                        if let content = result.choices.first?.message.content {
                            if let jsonData = content.data(using: .utf8) {
                                do {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        
                                        let newTitel = jsonObject["Titel"] as? String
                                        let newContent = jsonObject["Inhalt"] as? String
                                        let newHashtag = jsonObject["Hashtag"] as? String
                                        
                                        titleTextField.text = newTitel
                                        textTextView.text = newContent! + "\n \n" + newHashtag!
                                        
                                    } else {
                                        print("Der JSON-String ist nicht korrekt formatiert.")
                                    }
                                } catch {
                                    print("Fehler beim Parsen des JSON:", error)
                                }
                            }
                        }
                    }
                    catch{
                        print("Fehler beim Abrufen von Daten von OpenAI:", error)
                    }
                }
    }
    
}
