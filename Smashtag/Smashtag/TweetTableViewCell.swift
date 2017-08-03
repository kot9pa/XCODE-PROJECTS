//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Konstantin on 21.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    struct Palette {
        static let hashtagColor = UIColor.green
        static let urlColor = UIColor.blue
        static let userColor = UIColor.orange
    }
    
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        tweetTextLabel?.attributedText = setTextLabel(tweet)
        setProfileImageView(tweet) // async
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
    func setProfileImageView(_ tweet: Twitter.Tweet?) {
        tweetProfileImageView.image = nil
        guard let tweet = tweet, let profileImageURL = tweet.user.profileImageURL else { return }
        // async
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            let contentsOfURL = try? Data(contentsOf: profileImageURL)
            if profileImageURL == tweet.user.profileImageURL,
                let imageData = contentsOfURL {
                // UI -> go to main queue
                DispatchQueue.main.async {
                    self?.tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    private func setTextLabel(_ tweet: Twitter.Tweet?) -> NSMutableAttributedString {
        guard let tweet = tweet else {
            return NSMutableAttributedString(string: "")
        }
        var tweetText:String = tweet.text
        for _ in tweet.media { tweetText += " 📷" }
        
        let attributedText = NSMutableAttributedString(string: tweetText)
        attributedText.setMensionsColor(tweet.hashtags, color: Palette.hashtagColor)
        attributedText.setMensionsColor(tweet.urls, color: Palette.urlColor)
        attributedText.setMensionsColor(tweet.userMentions, color: Palette.userColor)
        
        return attributedText
    }
}

private extension NSMutableAttributedString {
    func setMensionsColor(_ mensions: [Twitter.Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
