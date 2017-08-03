//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Konstantin on 26.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "Image Cell"
private let segueIdentifier = "Show Image"

public struct TweetMedia: CustomStringConvertible {
        var tweet: Twitter.Tweet
        var media: MediaItem
        
        public var description: String { return "\(tweet): \(media)" }
}

class Cache: NSCache<NSURL, NSData> {
    subscript(key: URL) -> Data? {
        get {
            return object(forKey: key as NSURL) as Data?
        }
        set {
            if let data = newValue {
                setObject(data as NSData, forKey: key as NSURL,
                          cost: data.count / 1024)
            } else {
                removeObject(forKey: key as NSURL)
            }
        }
    }
}

class ImageCollectionViewController: UICollectionViewController {
    
    // MARK: - Public API
    
    var tweets: [Array<Twitter.Tweet>] = [] {
        didSet {
            images = tweets.flatMap({$0})
                .map({ tweet in
                    tweet.media.map({ TweetMedia(tweet: tweet, media: $0) }) })
                .flatMap({$0})
        }
    }
    
    var predefinedWidth:CGFloat {return floor(((collectionView?.bounds.width)! -
        FlowLayout.minimumColumnSpacing * (FlowLayout.ColumnCount - 1.0 ) -
        FlowLayout.sectionInset.right * 2.0) / FlowLayout.ColumnCount)}
    
    var sizePredefined:CGSize {return CGSize(width: predefinedWidth,
                                             height: predefinedWidth) }
    
    // MARK: - Internal structure
    
    private var images = [TweetMedia]()
    private var cache = Cache()
    
    private struct FlowLayout {
        static let MinImageCellWidth: CGFloat = 60
        
        static let ColumnCount:CGFloat = 3
        
        static let minimumColumnSpacing:CGFloat = 2
        static let minimumInteritemSpacing:CGFloat = 2
        static let sectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)
        
    }
    
    // MARK: - Functions
    
    private func setupLayout(){
        let layoutFlow = UICollectionViewFlowLayout()
        
        layoutFlow.minimumInteritemSpacing = FlowLayout.minimumInteritemSpacing
        layoutFlow.minimumLineSpacing = FlowLayout.minimumColumnSpacing
        layoutFlow.sectionInset = FlowLayout.sectionInset
        
        layoutFlow.itemSize = sizePredefined
        
        collectionView?.collectionViewLayout = layoutFlow
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let ivc = segue.destination as? ImageViewController,
                let cell = sender as? ImageCollectionViewCell {
                
                ivc.imageURL = cell.tweetMedia?.media.url
                ivc.title = cell.tweetMedia?.description
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell {
            
            imageCell.cache = cache
            imageCell.tweetMedia = images[indexPath.row]            
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
