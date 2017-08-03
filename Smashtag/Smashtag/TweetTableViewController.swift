//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Konstantin on 21.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController {
    
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            print(tweets)
        }
    }
    private var lastTwitterRequest: Twitter.Request?
    
    var searchText: String? {
        didSet {
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweet()
            title = searchText
            if let term = searchText {
                RecentSearches.add(term)
            }
        }
    }
    
    var newTweets = Array<Twitter.Tweet>() {
        didSet {
            insertTweets(newTweets)
        }
    }
    
    // MARK: - Internal structure
    
    private struct Storyboard {
        static let MentionsIdentifier = "Show Mentions"
        static let ImagesIdentifier = "Show Images"
        
    }
    
    // MARK: - Action
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweet()
    }

    @IBAction func search(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Search Tweets", message: "Enter #hashtag", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "#"
            textField.keyboardType = UIKeyboardType.twitter
            textField.autocorrectionType = UITextAutocorrectionType.no
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { Void in
            let textField = alert.textFields![0] as UITextField
            self.searchText = textField.text
            //print("Text field: \(textField.text)")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }

    private func searchForTweet() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets({ [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest && newTweets.count > 0 {
                        self?.insertTweets(newTweets)
                    } else if let numberOfSections = self?.tableView.numberOfSections,
                        numberOfSections > 0 {
                        self?.tableView.reloadSectionIndexTitles()
                    }
                    self?.refreshControl?.endRefreshing()
                }
            })
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func twitterRequest()  -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if searchText == nil, let searchLast = RecentSearches.searches.first {
            searchText = searchLast
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackToRecentButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackToRecentButton() {
        if let controllers = navigationController?.viewControllers, controllers.count > 1 {
            let toRecentButton = UIBarButtonItem(title: "Recents", style: .plain,
                                                 target: self,
                                                 action: #selector(toRootViewController))
            /*let toRecentButton = UIBarButtonItem(barButtonSystemItem: .undo,
                                                 target: self,
                                                 action: #selector(toRootViewController))*/
            navigationItem.setLeftBarButtonItems([toRecentButton], animated: true)
        }
    }
    
    func toRootViewController() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        
        //cell.textLabel?.text = tweet.text
        //cell.detailTextLabel?.text = tweet.user.name
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let currentDateTime = Date()
        //let newTweetsCount =
        
        if section == 0 {
            return "Updated: \(formatter.string(from: currentDateTime))"
        } else {
            return nil
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MentionsIdentifier:
                if let mtvc = segue.destination as? MentionsTableViewController,
                    let tweetCell = sender as? TweetTableViewCell {
                    
                        mtvc.tweet = tweetCell.tweet
                }
            case Storyboard.ImagesIdentifier:
                if let icvc = segue.destination as? ImageCollectionViewController {
                    icvc.tweets = tweets
                    icvc.title = "Images: \(searchText ?? "#")"
                }
            default: break
            }
        }
    }
    
}

let formatter: DateFormatter = {
    let formatter = DateFormatter()
    //formatter.timeStyle = .short
    //formatter.dateStyle = .short
    formatter.dateFormat = "dd/MM/yy HH:mm:ss"
    return formatter
    
}()
