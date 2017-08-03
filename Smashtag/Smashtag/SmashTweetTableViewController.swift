//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Konstantin on 16.06.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {
    
    var container: NSPersistentContainer? =
    (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        if searchText != nil {
            updateDatabase(with: newTweets)
        }
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("start loading db")
        container?.performBackgroundTask({ [weak self] context in
            /*for tweeterInfo in tweets {
                _ = try? Tweet.findTweetAndCheckMentions(for: tweeterInfo, with: (self?.searchText)!, in: context)
            }*/
            try? Tweet.newTweets(for: tweets, with: (self?.searchText)!, in: context)
            try? context.save()
            print("done loading")
            self?.printDatabaseStatistics()
        })
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("-on main thread")
                } else {
                    print("-off main thread")
                }
                // bad way to count
                if let tweetCount = (try? context.fetch( Tweet.fetchRequest() as NSFetchRequest<Tweet> ))?.count {
                    print("\(tweetCount) tweets")
                }
                // good way to count
                if let mentionsCount = try? context.count(for: Mention.fetchRequest()) {
                    print("\(mentionsCount) mentions")
                }
            }
        }
    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "Tweeters" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        }
    }*/

}
