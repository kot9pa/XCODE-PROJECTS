//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Konstantin on 26.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var cache: Cache?
    
    var tweetMedia: TweetMedia? {
        didSet {
            imageView.image = nil
            guard let url = tweetMedia?.media.url else { return }
            spinner?.startAnimating()
            
            if let imageData = cache?[url] {	// cached?
                spinner?.stopAnimating()
                imageView.image = UIImage(data: imageData)
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if url == self?.tweetMedia?.media.url,
                    let imageData = try? Data(contentsOf: url) {
                    
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: imageData)
                        
                        self?.cache?[url] = imageData
                        self?.spinner.stopAnimating()
                    }
                }
            }
        }
    }    
}
