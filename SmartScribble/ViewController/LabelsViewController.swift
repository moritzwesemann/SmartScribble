//
//  ViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class LabelsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notes: [Note] = [] {
        didSet{
            Note.saveToFiles(notes: notes)
        }
    }
    var uniqueTags: Set<String> = []
    var tagsArray: [String] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notes laden, falls welche gespeichert sind
        if let savedNotes = Note.loadFromFile(){
            notes = savedNotes
        }
        
        //LabesViewController ist für die Datenquelle der tableView verantwortlich
        tableView.dataSource = self
        
        // Tags Array erstellen (mithilfe eines Sets) um die dann auszugeben in der Label übersicht
        for note in notes {
                uniqueTags.formUnion(note.tags)
            }
        tagsArray = Array(uniqueTags)
        
        //Tagsarray sortieren
        tagsArray.sort()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Laden der Notizen aus der Datei
            if let savedNotes = Note.loadFromFile() {
                notes = savedNotes
            }

            // Tags Array aktualisieren
            uniqueTags.removeAll()
            for note in notes {
                uniqueTags.formUnion(note.tags)
            }
            tagsArray = Array(uniqueTags)
        
            //Tagsarray sortieren
            tagsArray.sort()
            
            // Tabelle neu laden
            tableView.reloadData()
        
            //Selection der vorher verwendeten Zeile entfernen
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: animated)
            }
        }
    
    // Anzahl der Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTags.count
    }
    
    //TableViewCell erstellen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tagsArray[indexPath.row]
        return cell
    }
    
    //Übergabe des Labels an DetailTagViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destinationVC = segue.destination as? DetailTagViewController,
               let selectedIndex = tableView.indexPathForSelectedRow?.row {
                destinationVC.selectedTag = tagsArray[selectedIndex]
            }
        }
    }

}

