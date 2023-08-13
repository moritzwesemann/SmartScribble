//  DetailTagViewController.swift
//  SmartScribble
//  Created by Moritz on 09.08.23.

import UIKit

class DetailTagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var notesTableView: UITableView!

    // MARK: - Properties
    var selectedTag: String?
    var notes: [Note] = [] {
        didSet {
            filterAndDisplayNotes()
        }
    }
    var filteredNotes: [Note] = [] // Stores the filtered notes based on selected tag
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "'Last edited:' dd.MM.yyyy HH:mm"
        return formatter
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAndSortNotes()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadAndSortNotes()
        filterAndDisplayNotes()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("didAddNewNote"), object: nil)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        self.navigationItem.title = selectedTag
        notesTableView.delegate = self
        notesTableView.dataSource = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNoteAdded), name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    // MARK: - Data Methods
    @objc func handleNewNoteAdded() {
        loadAndSortNotes()
        notesTableView.reloadData()
    }
    
    private func loadAndSortNotes() {
        if let loadedNotes = Note.loadFromFile() {
            notes = loadedNotes.sorted(by: { $0.lastEdited > $1.lastEdited })
        }
    }

    private func filterAndDisplayNotes() {
        filteredNotes = notes.filter { note in
            return note.tags.contains(selectedTag ?? "")
        }
        filteredNotes.sort(by: { $0.lastEdited > $1.lastEdited })
        notesTableView.reloadData()
    }

    // MARK: - Table View Data Source & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note = filteredNotes[indexPath.row]
        
        configureCell(cell, with: note)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, with note: Note) {
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cell.textLabel?.text = note.title

        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.text = dateFormatter.string(from: note.lastEdited)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteDetail",
           let destinationVC = segue.destination as? SingleNoteViewController,
           let indexPath = notesTableView.indexPathForSelectedRow?.row {
            destinationVC.noteID = filteredNotes[indexPath].id
        }
    }
}
