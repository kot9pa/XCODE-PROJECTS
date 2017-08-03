//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Konstantin on 25.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    // MARK: - Public API
    
    var tweet: Twitter.Tweet? {
        didSet {
            guard let tweet = tweet else { return }
            title = tweet.user.screenName
            mentionSections = initMensionSections(from: tweet)
            tableView.reloadData()
        }
    }
    
    // MARK: - Internal structure
    
    private var mentionSections = [MentionSection]()
    
    private struct MentionSection { //section
        var type: String
        var mentions: [MentionItem]
    }
    private enum MentionItem { //row
        case keyword(String)
        case image(URL, Double)
    }
    
    private struct Storyboard {
        static let KeywordCell = "Keyword Cell"
        static let ImageCell = "Image Cell"
        static let KeywordSegue = "From Keyword"
        static let ImageSegue = "Show Image"
        
    }
    
    private func initMensionSections(from tweet:Twitter.Tweet)-> [MentionSection]{
        var mentionSections = [MentionSection]()
        
        if  tweet.media.count > 0 {
            mentionSections.append(MentionSection(type: "Images",
                                                  mentions: tweet.media.map{ MentionItem.image($0.url, $0.aspectRatio)}))
        }
        if tweet.urls.count > 0 {
            mentionSections.append(MentionSection(type: "URLs",
                                                  mentions: tweet.urls.map{ MentionItem.keyword($0.keyword)}))
        }
        if tweet.hashtags.count > 0 {
            mentionSections.append(MentionSection(type: "Hashtags",
                                                  mentions: tweet.hashtags.map{ MentionItem.keyword($0.keyword)}))
        }
        var userItems = [MentionItem]()
        userItems += [MentionItem.keyword("@" + tweet.user.screenName)]
        
        if tweet.userMentions.count > 0 {
            userItems += tweet.userMentions.map({MentionItem.keyword($0.keyword)})
        }
        if userItems.count > 0 {
            mentionSections.append(MentionSection(type: "Users", mentions: userItems))
        }
        
        return mentionSections
    }

    // MARK: - Life Cycle
    
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
        return mentionSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentionSections[section].mentions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]
        
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Storyboard.KeywordCell,for: indexPath)
            cell.textLabel?.text = keyword
            return cell
            
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Storyboard.ImageCell, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageUrl = url
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentionSections[indexPath.section].mentions[indexPath.row]
        
        switch mention {
        case .image(_, let ratio):
            return tableView.bounds.size.width/CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].type
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.KeywordSegue:
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {
                        text += " OR from:" + text
                    }
                    ttvc.searchText = text
                }
            case Storyboard.ImageSegue:
                if let ivc = segue.destination as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {
                    
                    ivc.imageURL = cell.imageUrl
                    ivc.title = title
                }
            default: break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == Storyboard.KeywordSegue {
            if let cell = sender as? UITableViewCell,
                let indexPath =  tableView.indexPath(for: cell),
                mentionSections[indexPath.section].type == "URLs" {
                
                if let urlString = cell.textLabel?.text,
                    let url = URL(string: urlString) {
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                return false
            }
        }
        return true
    }
    
}
