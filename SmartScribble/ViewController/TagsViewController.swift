// ViewController.swift
// SmartScribble
// Created by Moritz on 09.08.23.

import UIKit

class TagsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    var uniqueTags: Set<String> = []
    var tagsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAndSortNotes()
        tableView.dataSource = self
        updateTagsArray()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNoteAdded), name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    @objc func handleNewNoteAdded() {
        loadAndSortNotes()
        updateTagsArray()
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndSortNotes()
        updateTagsArray()
        tableView.reloadData()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destinationVC = segue.destination as? DetailTagViewController,
           let selectedIndex = tableView.indexPathForSelectedRow?.row {
            destinationVC.selectedTag = tagsArray[selectedIndex]
        }
    }

    // Helper functions to clean up and avoid repetition
    private func loadAndSortNotes() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
        }
    }
    
    private func updateTagsArray() {
        uniqueTags.removeAll()
        for note in notes {
            uniqueTags.formUnion(note.tags)
        }
        tagsArray = Array(uniqueTags)
        tagsArray.sort()
    }
}
