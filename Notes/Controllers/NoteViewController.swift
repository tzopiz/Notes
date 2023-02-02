//
//  NoteViewController.swift
//  NOTES
//
//  Created by Дмитрий Корчагин on 31.01.2023.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    var activityViewController: UIActivityViewController? = nil
    var scrollView = UIScrollView()
    var textView = UITextView()
    let options = UIBarButtonItem()
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
    }
    private func setUpViews(){
        
        if selectedNote == nil{
            title = "New note"
            textView.text = ""
        } else {
            title = selectedNote?.name
            textView.text = selectedNote?.details
        }
        
        view.backgroundColor = res.colors.background
        let barButtonMenu = UIMenu(
            title: "", children: [
                UIAction(title: NSLocalizedString("Copy", comment: ""), image: res.images.image(named: "copy"), handler: copy),
                UIAction(title: NSLocalizedString("Rename", comment: ""), image: res.images.image(named: "rename"), handler: rename),
                UIAction(title: NSLocalizedString("Duplicate", comment: ""), image: res.images.image(named: "duplicate") , handler: duplicate),
                UIAction(title: NSLocalizedString("Delete", comment: ""), image: res.images.image(named: "delete"), handler: delete),
                UIAction(title: NSLocalizedString("Share", comment: ""), image: res.images.image(named: "share"), handler: share)
        ])
        options.image = res.images.image(named: "options")
        navigationItem.rightBarButtonItem = options
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        options.menu = barButtonMenu
        createScrollView()
        menuHandler()
    }
    @objc func back(){
        if isEditingNote {
            self.navigationController?.popViewController(animated: true)
            selectedNote?.name = title
            selectedNote?.details = textView.text
        } else {
           
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            
            newNote.id = noteList.count as NSNumber
            newNote.name = title
            newNote.details = textView.text
            do{
                try context.save()
                noteList.append(newNote)
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("context save error in @objc func back")
            }

        }
    }
    
    private func copy(action: UIAction) { }
    private func rename(action: UIAction) { }
    private func duplicate(action: UIAction) { }
    
    private func delete(action: UIAction){
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .alert)
        alertController.setValue(
            NSAttributedString(
                string: alertController.title!,
                attributes: [NSAttributedString.Key.font: res.fonts.font(named: "regular", 23)!,
                                NSAttributedString.Key.foregroundColor: UIColor.black]),
            forKey: "attributedTitle")

        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive) {
            (action) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    if (note == self.selectedNote) {
                        note.deletedDate = Date()
                        try context.save()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch {
                print("Fetch Failed")
            }
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionDelete)
        self.present(alertController, animated: true, completion: nil)
    }
    private func share(action: UIAction){
        self.activityViewController = UIActivityViewController(activityItems: [(title ?? "") + "\n" + (textView.text ?? "")], applicationActivities: nil)
        self.present(self.activityViewController!, animated: true)
    }
    
    private func createScrollView(){
        view.addSubview(scrollView)
        view.addSubview(textView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = res.colors.background
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = res.fonts.font(named: "regular", 23)
        textView.backgroundColor = res.colors.background
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -7),
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 7),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        
        
    }
    func menuHandler() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextField), name: UITextView.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextField), name: UITextView.keyboardWillHideNotification, object: nil)
    }
    @objc func updateTextField(_ sender: Notification){
            
        let userInfo = sender.userInfo
        let getKeyboardRect = (userInfo! [UIResponder.keyboardFrameEndUserInfoKey] as! NSValue ).cgRectValue
        let keyboardFrame = self.view.convert(getKeyboardRect, to: view.window)
        
        if sender.name == UITextView.keyboardWillHideNotification{
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
        
    }
}

