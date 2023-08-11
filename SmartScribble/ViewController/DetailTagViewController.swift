//
//  DetailTagViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class DetailTagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notesTableView: UITableView!
    
    var selectedTag: String?
    
    var notes: [Note] = [] {
        didSet {
            filterAndDisplayNotes()
        }
    }
    
    var filteredNotes: [Note] = [] // Hält die gefilterten Notizen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setzen des Titles der NavigationBar nach dem Label
        self.navigationItem.title = selectedTag
        
        //Für die Datensource ist die Klasse selber verantwortlich
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        // Laden Sie die Notizen aus der Datei
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Laden der Notizen aus der Datei
            if let loadedNotes = Note.loadFromFile() {
                notes = loadedNotes
            }
            
            // Durchsucht die Notizen nach dem ausgewählten Tag und zeigt sie an
            filterAndDisplayNotes()
        }
    
    // Durchsucht die Notizen nach dem ausgewählten Tag und zeigt sie an
    func filterAndDisplayNotes() {
        filteredNotes = notes.filter { note in
            return note.tags.contains(selectedTag ?? "")
        }
        
        // Aktualisiert die TableView, um die gefilterten Notizen anzuzeigen
        notesTableView.reloadData()
    }

    // MARK: - Table view data source

    //Anzahl der Rows entsprechend den relevanten Notizen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    //Erstellen der Zellen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)

        let note = filteredNotes[indexPath.row]
        cell.textLabel?.text = note.title // Setzt den Titel der jeweiligen Notiz

        return cell
    }
    
    
    
    //Übergabe der NoteID an SingleNoteViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showNoteDetail", let destinationVC = segue.destination as? SingleNoteViewController, let indexPath = notesTableView.indexPathForSelectedRow?.row {
                // Übergeben Sie die ausgewählte Notiz an den neuen View Controller
                destinationVC.noteID = filteredNotes[indexPath].id
                print(filteredNotes[indexPath])
            }
        }
    

}