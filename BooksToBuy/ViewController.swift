

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet weak var tableView: UITableView!
    var nameArr = [String]()
    var idArr = [UUID]()
    
    var selectedBook = ""
    var selectedBookId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // navigationBar (+)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: self,
            action: #selector(navigateAddBtn))
        
        
        
        // for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        
        getDatas()
    }
    
    
    // ADD BTN - Clicked navigate btn when to go detail-
    @objc func navigateAddBtn(){
        selectedBook = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDatas),
                                               name: NSNotification.Name(rawValue: "bookData"), object: nil)
    
    }
    
    
    
    
    // GET DATA
   @objc func getDatas() {
       
       //  remove for Duplicate datas
       nameArr.removeAll(keepingCapacity: false)
       idArr.removeAll(keepingCapacity: false)
       
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do {
            let bookDatas = try context.fetch(fetchRequest)
            
            if bookDatas.count > 0 {
                for book in bookDatas as! [NSManagedObject] {
                    
                    
                    if let name = book.value(forKey:"name") as? String {
                        self.nameArr.append(name)
                    }
                    
                    if let id = book.value(forKey: "id") as? UUID {
                        self.idArr.append(id)
                    }
                    
                   
                    self.tableView.reloadData() // Refresh Datas
                }
            }
            
        } catch {
            print("Fetch ERR!")
        }
        
    }
    
    
    
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    
    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        
        cell.textLabel?.text = nameArr[indexPath.row]
      
        return cell
    }
    
    
    // prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  //segue başlamadan önce çalışacak fonksiyon
       
        if segue.identifier == "toDetailsVC" {
            let  destinationVC =  segue.destination as! DetailsViewController
            
            // hedefin.fieldı         // gidelen_yerin_fieldı
            destinationVC.bookSelected = selectedBook
            destinationVC.bookSelectedId = selectedBookId
        }
        
    }
    
    
    
    // didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = nameArr[indexPath.row]
        selectedBookId = idArr[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)        // Segue olsun toDetailsVC'ye
    }
    
    
    // commit editingStyle -> delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            
            // 1- get to db then delete id with id
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
            
            let idStr = idArr[indexPath.row].uuidString
            
            
            fetchRequest.predicate  = NSPredicate(format: "id = %@", idStr)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do {
                let getBookArr = try context.fetch(fetchRequest)
                
                if getBookArr.count > 0 {
                    for book in getBookArr as! [NSManagedObject] {
                        
                        if let id = book.value(forKey: "id") as? UUID {
                            
                            
                            if id ==  idArr[indexPath.row] {   //db id ==  clickedRow.id
                                context.delete(book)
                                nameArr.remove(at: indexPath.row)   // delete and return specified position ele
                                idArr.remove(at: indexPath.row)
                            
                        
                                self.tableView.reloadData() // Madem sildik tableView reload,  q-table refresh gibi..
                                
                                do {
                                    try context.save()
                                    
                                } catch {
                                    print("ERR!")
                                }
                                
                            }
                                 
                        }
                        
                    }
                    
                }
                
                
                
            } catch {
                print("Delete ERR!")
            }
            
            
            
            
            
        }
        
    }


}

