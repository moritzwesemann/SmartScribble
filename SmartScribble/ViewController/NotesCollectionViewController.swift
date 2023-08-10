//
//  NotesCollectionViewController.swift
//  SmartScribble
//
//  Created by Moritz on 10.08.23.
//

// Importiert das UIKit-Framework, um UI-Klassen zu verwenden
import UIKit

// Definiert die NotesCollectionViewController-Klasse, die die Protokolle für UICollectionView implementiert
class NotesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Outlet für die UICollectionView, in der die Notizen angezeigt werden
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    // Array von Notizen, die in der Sammlung angezeigt werden sollen
    var notes: [Note] = []
    
    // Wird aufgerufen, wenn die Ansicht geladen wird; Setup-Code
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setzt den Delegierten und die Datenquelle für die Sammlung
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
        
        // Lädt die Notizen aus einer Datei
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Aktualisieren Sie die Notizen, wenn der ViewController sichtbar wird
            if let loadedNotes = Note.loadFromFile() {
                notes = loadedNotes
                notesCollectionView.reloadData() // Löst eine Aktualisierung der Sammlung aus
            }
        }
    
    // Gibt die Größe für eine Zelle an einer bestimmten Position zurück
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 200) // Stelle die gewünschte Breite und Höhe ein
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
        cell.textLabel.text = String(note.text.prefix(50)) // Zeigt die ersten 50 Zeichen des Textes

        // Rahmen und abgerundete Ecken hinzufügen
        cell.layer.borderWidth = 1.0 // Dicke des Rahmens
        cell.layer.borderColor = UIColor.black.cgColor // Farbe des Rahmens
        cell.layer.cornerRadius = 8.0 // Radius der Ecken
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteDetail", let destinationVC = segue.destination as? SingleNoteViewController, let indexPath = notesCollectionView.indexPathsForSelectedItems?.first {
            // Übergeben Sie die ausgewählte Notiz an den neuen View Controller
            destinationVC.selectedNoteIndex = indexPath.row
        }
    }


}
