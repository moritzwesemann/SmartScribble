// ViewController.swift
// SmartScribble
// Created by Moritz on 09.08.23.

import UIKit

class TagsViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var notes: [Note] = [] {
        didSet {
            Note.saveToFiles(notes: notes)
        }
    }
    var uniqueTags: Set<String> = []
    var tagsArray: [String] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAndSortNotes()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshDataAndView()
        deselectSelectedRow(animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("didAddNewNote"), object: nil)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        tableView.dataSource = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNoteAdded), name: NSNotification.Name("didAddNewNote"), object: nil)
    }
    
    // MARK: - Data Handling
    @objc func handleNewNoteAdded() {
        refreshDataAndView()
    }
    
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
    
    private func refreshDataAndView() {
        loadAndSortNotes()
        updateTagsArray()
        tableView.reloadData()
    }
    
    private func deselectSelectedRow(animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tagsArray[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destinationVC = segue.destination as? DetailTagViewController,
           let selectedIndex = tableView.indexPathForSelectedRow?.row {
            destinationVC.selectedTag = tagsArray[selectedIndex]
        }
    }
}
