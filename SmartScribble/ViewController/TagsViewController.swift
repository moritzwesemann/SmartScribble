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
    var notesWithoutTags: Int = 0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAndSortNotes()
        setupNotifications()
        
        let clockSymbol = UIImage(systemName: "tag")
        let imageView = UIImageView(image: clockSymbol)
        imageView.tintColor = UIColor.gray  // Setzt die Farbe des Symbols auf Grau
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)  // Ändert die Größe des Bildes
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
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
        tableView.separatorStyle = .none
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
        notesWithoutTags = 0
        
        for note in notes {
            if note.tags.isEmpty {
                notesWithoutTags += 1
            } else {
                uniqueTags.formUnion(note.tags)
            }
        }
        
        tagsArray = Array(uniqueTags)
        tagsArray.sort()
        
        // Falls es Notizen ohne Tags gibt, den "Ohne Label"-Eintrag am Anfang des Arrays hinzufügen
        if notesWithoutTags > 0 {
            tagsArray.insert("Sonstiges", at: 0)
        }
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
        return uniqueTags.count + (notesWithoutTags > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TagTableViewCell

        if indexPath.row == 0 && notesWithoutTags > 0 {
            cell.tagLabel.text = "Sonstiges"
        } else {
            cell.tagLabel.text = "#" + tagsArray[indexPath.row]
        }
        
        cell.selectionStyle = .none
        
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
