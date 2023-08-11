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
        
        //Setzt den Delegierten und die Datenquelle für die Sammlung
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
        
        //Lädt die Notizen aus einer Datei
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            //Aktualisieren der Notizen, wenn der ViewController sichtbar wird
            if let loadedNotes = Note.loadFromFile() {
                notes = loadedNotes.sorted(by:  { $0.lastEdited > $1.lastEdited })
                
                notesCollectionView.reloadData() // Löst eine Aktualisierung der Sammlung aus
            }
        }
    
    //Hashtags extrahieren
    func extractHashtags(from text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "#(\\w+)", options: [])
            let results = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch let error {
            print("Fehler beim Extrahieren von Hashtags: \(error.localizedDescription)")
            return []
        }
    }
    

    //Abstand zwischen den Zellen einstellen
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Dies ist der horizontale Abstand. Sie können den Wert ändern, um den gewünschten Abstand zu erhalten.
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0 // Dies ist der vertikale Abstand. Sie können den Wert ändern, um den gewünschten Abstand zu erhalten.
    }
    
    // Gibt die Anzahl der Abschnitte in der Sammlung zurück
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Gibt die Anzahl der Elemente in einem Abschnitt zurück
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    // Erstellt und konfiguriert eine Zelle an einer bestimmten Position
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = notesCollectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NoteCollectionViewCell
        let note = notes[indexPath.row]
        
        // Setzt den Titel und den Textvorschau für die Zelle
        cell.titleLabel.text = note.title
        cell.contentTextField.text = String(note.text.prefix(230))
        
        // Hashtags extrahieren und setzen
        let hashtags = extractHashtags(from: note.text)
        cell.tagsLabel.text = hashtags.joined(separator: " ")
        

        // Rahmen und abgerundete Ecken hinzufügen
        cell.layer.borderWidth = 1.0 // Dicke des Rahmens
        cell.layer.borderColor = UIColor.black.cgColor // Farbe des Rahmens
        cell.layer.cornerRadius = 8.0 // Radius der Ecken
        
        //Textfeld Interaction entfernt
        cell.contentTextField.isUserInteractionEnabled = false
        
        return cell
    }
    
    //Übergang zu SingleNoteViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteDetail", let destinationVC = segue.destination as? SingleNoteViewController, let indexPath = notesCollectionView.indexPathsForSelectedItems?.first {
            // Übergeben Sie die ausgewählte Notiz an den neuen View Controller
            destinationVC.noteID = notes[indexPath.row].id
            print(notes[indexPath.row].id)
            print(indexPath.row)
        }
    }


}
