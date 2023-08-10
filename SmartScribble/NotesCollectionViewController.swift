//
//  NotesCollectionViewController.swift
//  SmartScribble
//
//  Created by Moritz on 10.08.23.
//

import UIKit

class NotesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    var notes: [Note] = []
    
    override func viewDidLoad() {
           super.viewDidLoad()
            notesCollectionView.delegate = self
            notesCollectionView.dataSource = self
            if let loadedNotes = Note.loadFromFile() {
                    notes = loadedNotes
                }
        print(notes)
           
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 200) // Stelle die gewünschte Breite und Höhe ein
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = notesCollectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
            let note = notes[indexPath.row]
            
            cell.titleLabel.text = note.title
            cell.textPreviewTextView.text = String(note.text.prefix(50)) // Zeigt die ersten 50 Zeichen des Textes

            // Rahmen hinzufügen
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.black.cgColor // Farbe des Rahmens

            // Abgerundete Ecken hinzufügen
            cell.layer.cornerRadius = 8.0 // Radius der Ecken
            
            return cell
    }
    

   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
