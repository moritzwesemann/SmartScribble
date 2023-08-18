//  NoteViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

import UIKit
import Speech
import OpenAI

class NewNoteViewController: UIViewController, SFSpeechRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var newNoteView: UIView!
    @IBOutlet weak var noteTitleLabel: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dictateButton: UIButton!
    
    // MARK: - Properties
    var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    private var recordedText: String?
    
    //KI-Funktion
    var note = Note(title: "", text: "", tags: [], lastEdited: Date())
    var openAI:OpenAI?
    
    var uniqueTags: Set<String> = []
    var tagsArray: [String] = []
    var notesWithoutTags: Int = 0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData()
        updateTagsArray()
        openAI = OpenAI(apiToken: getApiKey())

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
  


    // MARK: - Configuration Methods
    private func configureUI() {
        updateSaveButtonState()
        noteTitleLabel.addTarget(self, action: #selector(titleDidChange), for: .editingChanged)
        
        newNoteView.styleAsNoteView()
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
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { $0.hasPrefix("#") }.map { String($0.dropFirst()) }
    }
    
    // MARK: - User Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let title = noteTitleLabel.text, !title.isEmpty,
              let textContent = noteTextView.text else { return }
        
        let newNote = Note(title: title,
                           text: textContent,
                           tags: extractHashtags(from: textContent),
                           lastEdited: Date())
        notes.append(newNote)
        
        NotificationCenter.default.post(name: NSNotification.Name("didAddNewNote"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        do {
            try startRecording()
            presentRecordingAlert()
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error)")
        }
    }
    
    @IBAction func kiButtonPressed(_ sender: Any)  {
        guard let title = noteTitleLabel.text, !title.isEmpty ,
              let textContent = noteTextView.text else { return }
        
        note = Note(title: title, text: textContent, tags: extractHashtags(from: textContent), lastEdited: Date())
        
        var noteString = "Title: \(note.title)\nText: \(note.text)\nTags: \(note.tags.joined(separator: ", "))"
        
        let promptString = """
        Ich habe eine Notiz und möchte, dass du sie in eine prägnante und gut strukturierte Form bringst. Der Titel sollte kurz und beschreibend sein, z.B. "Informatik Vorlesung". Der Inhalt sollte weniger aus Fließtext und mehr aus Bereichen bestehen die mit einem Absatz separiert sind, die die Hauptthemen abdecken und Stichpunkte die Aufgaben und informationen zusammenfassen. Bitte organisiere und strukturiere die folgende Notiz entsprechend und füge einen relevanten Hashtag hinzu (bevorzugt aus der Liste: \(uniqueTags)).Achte darauf, dass ich die Anwtwort mithlfe der JSONSerialization Methode in JSON übersetzen kann:
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
                                
                                noteTitleLabel.text = newTitel
                                noteTextView.text = newContent! + "\n \n" + newHashtag!
                                
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
    
    // MARK: - Recording Methods
    func presentRecordingAlert() {
        let alertController = UIAlertController(title: "Aufnahme", message: "Sprich jetzt...\n\n\n\n\n", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
            self?.stopRecording()
            if let transcription = alertController.message?.components(separatedBy: "\n").last {
                self?.noteTextView.text = transcription
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel) { [weak self] _ in
            self?.stopRecording()
            self?.noteTextView.text = ""
        })
        
        let microphoneImage = UIImage(systemName: "mic.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        alertController.setValue(microphoneImage, forKey: "image")

        self.present(alertController, animated: true)
    }

    func startRecording() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, _ in
            if let transcription = result?.bestTranscription {
                DispatchQueue.main.async {
                    self?.updateAlertMessage(with: transcription.formattedString)
                }
            }
        })
    }
    
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        guard let recordedVoiceText = recordedText, !recordedText!.isEmpty else {return}

        let promptString = """
        Ich habe eine Notiz und möchte, dass du sie in eine prägnante und gut strukturierte Form bringst. Der Titel sollte kurz und beschreibend sein, z.B. "Informatik Vorlesung". Der Inhalt sollte weniger aus Fließtext und mehr aus Bereichen bestehen die mit einem Absatz separiert sind, die die Hauptthemen abdecken und Stichpunkte die Aufgaben und informationen zusammenfassen. Bitte organisiere und strukturiere die folgende Notiz entsprechend und füge einen relevanten Hashtag hinzu (bevorzugt aus der Liste: \(uniqueTags)).Achte darauf, dass ich die Anwtwort mithilfe der JSONSerialization Methode aus Swift in JSON übersetzen kann:
        {
          "Titel": "DEIN KORRIGIERTER TITEL",
          "Inhalt": "DEIN KORRIGIERTER INHALT",
          "Hashtag": "#DEIN_HASHTAG"
        }
        Text:
        \(recordedVoiceText)
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
                                        
                                        noteTitleLabel.text = newTitel
                                        noteTextView.text = newContent! + "\n \n" + newHashtag!
                                        updateSaveButtonState()
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
    
    func updateAlertMessage(with message: String) {
        if let alertController = self.presentedViewController as? UIAlertController {
            alertController.message = "Sprich jetzt...\n\n\n\(message)\n\n"
            self.recordedText = message
        }
    }
}

extension UIView {
    func styleAsNoteView() {
        let customGray = UIColor(white: 0.95, alpha: 1.0)
        backgroundColor = customGray
        layer.cornerRadius = 5.0
        clipsToBounds = true
        layer.masksToBounds = false // Needed for shadow
    }
}
