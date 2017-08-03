//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by Konstantin on 25.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class RecentTableViewController: UITableViewController {
    
    // MARK: - Model
    
    var recentSearches: [String] {
        return RecentSearches.searches
    }
    
    private struct Storyboard {
        static let RecentCell = "Recent Cell"
        static let TweetsSegue = "From Recents"
        static let PopularSegueIdentifier = "ShowPopularMensions"
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        tableView.reloadData()
        navigationItem.setLeftBarButton(nil, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recentSearches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.RecentCell, for: indexPath)

        cell.textLabel?.text = recentSearches[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            RecentSearches.removeAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.TweetsSegue:
                if let cell = sender as? UITableViewCell,
                    let ttvc = segue.destination as? TweetTableViewController {
                    ttvc.searchText = cell.textLabel?.text
                }
            case Storyboard.PopularSegueIdentifier:
                if let cell = sender as? UITableViewCell,
                    let pvc = segue.destination as? PopularTableViewController {
                    pvc.mention = cell.textLabel?.text
                    pvc.container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
                    pvc.title = "Popularity for " + (cell.textLabel?.text ?? "")
                }
            default:
                break
            }
        }
    }

}
