//
//  DetailViewController.swift
//  MoviesViewer
//
//  Created by Michael Bock on 2/6/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: infoView.frame.origin.y + infoView.frame.size.height)

        let title = movie["title"] as! String
        titleLabel.text = title

        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()

        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            let imageURLRequest = NSURLRequest(URL: imageURL!)

            posterImageView.setImageWithURLRequest(
                imageURLRequest,
                placeholderImage: nil,
                success: { (imageURLRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                        })
                    } else {
                        self.posterImageView.image = image
                    }
                }, failure: { (imageURLRequest, imageResponse, error) -> Void in
                    // Do something here
            })
        }
    }

}
