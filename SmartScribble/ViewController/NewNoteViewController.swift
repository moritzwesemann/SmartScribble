//  NoteViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

import UIKit
import Speech


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
        
        // Custom gray color
        let customGray = UIColor(white: 0.95, alpha: 1.0)

        // For noteView
        newNoteView.backgroundColor = customGray
        newNoteView.layer.cornerRadius = 5.0
        newNoteView.clipsToBounds = true
        newNoteView.layer.masksToBounds = false // Da wir einen Schatten verwenden, sollten wir dies auf false setzen
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
    
    @IBAction func onButtonPressed(_ sender: Any) {
        do {
            try startRecording()
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error)")
            return
        }

        let alertController = UIAlertController(title: "Aufnahme", message: "Sprich jetzt...\n\n\n\n\n", preferredStyle: .alert) // Extra newlines for layout space

        let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
            self?.stopRecording()
            if let transcription = alertController.message?.components(separatedBy: "\n").last {
                self?.noteTextView.text = transcription
                print("Aufgezeichneter Text: \(self?.recordedText)")
            }
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { [weak self] _ in
            self?.stopRecording()
            self?.noteTextView.text = ""
        }
        alertController.addAction(cancelAction)
        
        let microphoneImage = UIImage(systemName: "mic.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        alertController.setValue(microphoneImage, forKey: "image")

        self.present(alertController, animated: true, completion: nil)
    }


    
    func startRecording() throws {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, _) in
            if let transcription = result?.bestTranscription {
                DispatchQueue.main.async {
                    if let alertController = self.presentedViewController as? UIAlertController {
                        alertController.message = "Sprich jetzt...\n\n\n\(transcription.formattedString)\n\n"
                        self.recordedText = transcription.formattedString
                    }
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
}
