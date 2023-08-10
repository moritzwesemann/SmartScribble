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
    
    var notes: [Note] = [] {
            didSet {
                Note.saveToFiles(notes: notes)
            }
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Laden Sie vorhandene Notizen
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        
            var newNote = Note(title: noteTitleLabel.text ?? "", text: noteTextView.text, tags: [], lastEdited: Date())
            
            
                notes.append(newNote)
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
