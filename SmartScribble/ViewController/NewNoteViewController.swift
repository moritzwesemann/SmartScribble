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
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadData()
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
    
    // MARK: - API Abfrage
  


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
    
    @IBAction func kiButtonPressed(_ sender: Any) {
        guard let title = noteTitleLabel.text, !title.isEmpty ,
              let textContent = noteTextView.text else { return }
        
        note = Note(title: title, text: textContent, tags: extractHashtags(from: textContent), lastEdited: Date())
        
        var noteString = "Title: \(note.title)\nText: \(note.text)\nTags: \(note.tags.joined(separator: ", "))"
        let promptString = """
        Gegeben ist eine Notiz. Korrigiere den Titel, strukturiere und formatiere den Inhalt klar, indem du Listen oder Absätze erstellst, wo sinnvoll. Füge auch einen Hashtag zur Kategorisierung hinzu. Das Ergebnis soll im folgenden JSON-ähnlichen Format zurückgegeben werden:
        {
          "Titel": "DEIN KORRIGIERTER TITEL",
          "Inhalt": "DEIN KORRIGIERTER INHALT",
          "Hashtag": "#DEIN_HASHTAG"
        }
        Notiz:
        \(noteString)
        """

        
        
        let query = CompletionsQuery(model: .textDavinci_003, prompt: promptString, temperature: 0, maxTokens: 200, topP: 1, frequencyPenalty: 0, presencePenalty: 0)
        openAI!.completions(query: query) { [self] result in
                    switch result {
                    case .success(let completionsResult):
                        if let firstChoice = completionsResult.choices.first {
                            let answerText = firstChoice.text
                            print(answerText)
                            if let jsonData = answerText.data(using: .utf8) {
                                do {
                                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] {
                                        let newTitle = jsonObject["Titel"]
                                        let newText = jsonObject["Inhalt"]
                                        let hashtag = jsonObject["Hashtag"]
                                        
                                        DispatchQueue.main.async {
                                            self.noteTitleLabel.text = newTitle
                                            self.noteTextView.text = newText! + "\n" + hashtag!
                                            // Falls Sie den Hashtag auch anzeigen/verwenden möchten, können Sie hier weitere Aktionen hinzufügen
                                        }
                                    }
                                } catch {
                                    print("Fehler bei der JSON-Konvertierung: \(error.localizedDescription)")
                                }
                            }
                        }
                    case .failure(let error):
                        print("Es gab einen Fehler: \(error)")
                    }
                }
        
        
    }
    
    func testKI(){
        let query = CompletionsQuery(model: .textDavinci_003, prompt: "Überarbeite mir diese Notiz: Einkausliste 1. Banane 2. Apffel 3. SHinken", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        openAI!.completions(query: query) { result in
            switch result {
            case .success(let completionsResult):
                if let firstChoice = completionsResult.choices.first {
                    let answerText = firstChoice.text
                    print(answerText) // Gibt den Text aus
                }
            case .failure(let error):
                print("Es gab einen Fehler: \(error)")
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
                print("Aufgezeichneter Text: \(self?.recordedText ?? "")")
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
