//
//  ViewController.swift
//  SmartScribble
//
//  Created by Moritz on 09.08.23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    
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
        
        if let savedNotes = Note.loadFromFile(){
            notes = savedNotes
        }
        
        tableView.dataSource = self
        
        // Tags Array erstellen um die dann auszugeben in der Label übersicht
        for note in notes {
                uniqueTags.formUnion(note.tags)
            }
        tagsArray = Array(uniqueTags)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tagsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destinationVC = segue.destination as? DetailTagViewController,
               let selectedIndex = tableView.indexPathForSelectedRow?.row {
                destinationVC.selectedTag = tagsArray[selectedIndex]
            }
        }
    }

}

