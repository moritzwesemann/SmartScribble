//
//  NoteViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var noteTitleLabel: UITextField!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var notes: [Note] = [] {
            didSet {
                Note.saveToFiles(notes: notes)
            }
        }
    
    var newNote: Note?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTitleLabel.delegate = self
        noteTextView.delegate = self
        
        // Laden Sie vorhandene Notizen
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }

        
        // Wenn es eine vorhandene Notiz gibt, setze die Werte in die Textfelder
        if let note = newNote {
            noteTitleLabel.text = note.title
            noteTextView.text = note.text
        } else {
            // Wenn keine vorhandene Notiz, erstelle eine neue mit leeren Werten und aktuellem Datum
            newNote = Note(title: "", text: "", tags: [], lastEdited: Date())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Aktualisieren Sie die Note mit den neuesten Daten
            newNote?.title = noteTitleLabel.text ?? ""
            newNote?.text = noteTextView.text
            newNote?.lastEdited = Date()
            
            if let note = newNote {
                notes.append(note)
            }
        print(notes)
        }
    
    //hier müssen die Tags noch hinzugefügt werden
    
    
    
    
    
  /*  func textFieldDidChangeSelection(_ textField: UITextField) {
           if let title = textField.text {
               newNote?.title = title
           }
        print(newNote)
       }
    
    func textViewDidChange(_ textView: UITextView) {
            newNote?.text = textView.text!
        print(newNote)
        }
    */

}
