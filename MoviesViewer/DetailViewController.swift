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
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width,
            height: infoView.frame.origin.y + infoView.frame.size.height)

        let title = movie["title"] as! String
        titleLabel.text = title
        navigationItem.title = title

        let stars = movie["vote_average"] as! Double
        starLabel.text = "\(stars)/10 ⭐"

        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()

        fetchAndSetPosterImages()
    }

    func fetchAndSetPosterImages() {
        let smallBaseURL = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie["poster_path"] as? String {
            let smallImageURL = NSURL(string: smallBaseURL + posterPath)
            let smallImageURLRequest = NSURLRequest(URL: smallImageURL!)

            posterImageView.setImageWithURLRequest(
                smallImageURLRequest,
                placeholderImage: nil,
                success: { (smallImageURLRequest, smallImageResponse, smallImage) -> Void in
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage

                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.posterImageView.alpha = 1.0
                        }, completion: { (success) -> Void in
                            self.fetchAndSetLargerImage()
                    })
                }, failure: { (imageURLRequest, imageResponse, error) -> Void in
                    // Do something here
            })
        }
    }

    func fetchAndSetLargerImage() {
        let largeBaseURL = "https://image.tmdb.org/t/p/original"
        if let posterPath = movie["poster_path"] as? String {
            let largeImageURL = NSURL(string: largeBaseURL + posterPath)
            let largeImageURLRequest = NSURLRequest(URL: largeImageURL!)
            self.posterImageView.setImageWithURLRequest(
                largeImageURLRequest,
                placeholderImage: nil,
                success: { (largeImageURLRequest, largeImageResponse, largeImage) -> Void in
                    self.posterImageView.image = largeImage
                },
                failure: { (imageURLRequest, imageResponse, error) -> Void in
                    // Do something here
            })
        }
    }

}
