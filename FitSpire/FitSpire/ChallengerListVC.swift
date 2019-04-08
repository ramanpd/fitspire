//
//  ChallengerListVC.swift
//  FitSpire
//
//  Created by Raman Prasad on 03/04/19.
//  Copyright © 2019 Connor Clancy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var users = [User]()
var myIndex = 0
class ChallengerListVC: UITableViewController {

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fetchUser()
    {
        

        Database.database().reference().child("users").observe(.childAdded, with: {(DataSnapshot) in print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.username = dictionary["username"]
                user.facebookId = DataSnapshot.key as AnyObject
                users.append(user)
                DispatchQueue.main.async{
                    
                    self.tableView.reloadData()
                }
                print(user.username!)
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath)
    {
        myIndex = indexPath.row
        print(users[myIndex].username!)
        performSegue(withIdentifier: "goToWaitVC", sender: self)
    }
    
    

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username as! String
        //print("lololololol")
        //print(user.facebookId as! String)
        let url = NSURL(string: "https://graph.facebook.com/\(user.facebookId!)/picture?type=large&return_ssl_resources=1")
//        let url = URL(string: "https://graph.facebook.com/\(user.facebookId!)/picture?type=large&return_ssl_resources=1")
//        let session = URLSession.shared
//        let task = session.dataTask(with: url!, MTLNewLibraryCompletionHandler{
//            (data,response, error) in
//            if error != nil{
//                print(error)
//                return
//            }
//            DispatchQueue.main.async {
//                cell.imageView?.image = UIImage(data: data!)
//            }
//
//        }).resume()
        
        cell.imageView?.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
class UserCell: UITableViewCell
{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
