//
//  ViewController.swift
//  Notes
//
//  Created by Дмитрий Корчагин on 02.02.2023.
//

import UIKit
import CoreData

var isEditingNote = false

class RootViewController: UITableViewController {
    

    let cellIndentifier = "Cell"
    var firstLoad = true
    
    override func viewDidLoad(){
        if (firstLoad) {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    noteList.append(note)
                }
            }
            catch {
                print("Fetch Failed")
            }
        }
        setUpView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    private func setUpView(){
        createTableView()
        changeNavVC()
    }
    
    private func createTableView(){
        tableView = createTable(frame: CGRect.zero, style: .plain, backgroundColor: res.colors.background)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIndentifier)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonDeletedNotes().count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let thisNote: Note!
        thisNote = nonDeletedNotes()[indexPath.row]
        let selectionColor = UIView() as UIView
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIndentifier)

        selectionColor.layer.borderWidth = 0
        selectionColor.layer.borderColor = res.colors.separator.cgColor
        selectionColor.backgroundColor = res.colors.separator

        var content = cell.defaultContentConfiguration()
        content.text = thisNote.name
        content.secondaryText = thisNote.details
        content.textProperties.font = res.fonts.font(named: "bold", 22)!
        content.secondaryTextProperties.font = res.fonts.font(named: "regular", 12)!
        content.textProperties.numberOfLines = 1
        content.secondaryTextProperties.numberOfLines = 1
        content.image = res.images.image(named: "cell")
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.selectedBackgroundView = selectionColor
        cell.selectedBackgroundView?.backgroundColor = res.colors.secondary
        
        cell.backgroundColor = res.colors.background
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isEditingNote = true
        
        let vc = NoteViewController()
        let selectedNote: Note!
        selectedNote = nonDeletedNotes()[indexPath.row]
        vc.selectedNote = selectedNote
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = noteList[sourceIndexPath.row]
        noteList.remove(at: sourceIndexPath.row)
        noteList.insert(item, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        tableView.beginUpdates()
        noteList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) { }
    func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation){ }
    func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) { }
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) { }
    
    // MARK: - create UI
    private func createTable(frame: CGRect, style: UITableView.Style, backgroundColor: UIColor = .white) -> UITableView {
        let myTableView = UITableView(frame: frame, style: style)
        myTableView.backgroundColor = backgroundColor
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myTableView.delegate = self
        myTableView.dataSource = self
        
        return myTableView
    }
    private func changeNavVC(){
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = res.colors.background
        appearance.titleTextAttributes = [.foregroundColor: res.colors.titleGray]
        
        
        view.backgroundColor = res.colors.background
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNote)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(buttonEdit))
        ]
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = "Notes"
        
    }
    
    @objc func buttonEdit() { tableView.isEditing = !tableView.isEditing }
    @objc func createNote(){
        isEditingNote = false
        let vc = NoteViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func nonDeletedNotes() -> [Note] {
        var noDeleteNoteList = [Note]()
        for note in noteList
        {
            if(note.deletedDate == nil)
            {
                noDeleteNoteList.append(note)
            }
        }
        return noDeleteNoteList
    }
}
