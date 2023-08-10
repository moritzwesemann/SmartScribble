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
    var tagsArray: [String] = []
    
    var notes: [Note] = [] {
        didSet {
            filterAndDisplayNotes()
        }
    }
    
    var filteredNotes: [Note] = [] // Hält die gefilterten Notizen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedTag)
        self.navigationItem.title = selectedTag
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        // Laden Sie die Notizen aus der Datei
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes
        }
    }
    
    // Durchsucht die Notizen nach dem ausgewählten Tag und zeigt sie an
    func filterAndDisplayNotes() {
        filteredNotes = notes.filter { note in
            return note.tags.contains(selectedTag ?? "")
        }
        
        // Aktualisiert die TableView, um die gefilterten Notizen anzuzeigen
        print(filteredNotes)
        notesTableView.reloadData()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)

        let note = filteredNotes[indexPath.row]
        cell.textLabel?.text = note.title // Setzt den Titel der jeweiligen Notiz

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
