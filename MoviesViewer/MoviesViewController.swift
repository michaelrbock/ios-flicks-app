//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by Michael Bock on 2/6/16.
//  Copyright © 2016 Michael R. Bock. All rights reserved.
//

import AFNetworking
import MBProgressHUD
import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl!

    var movies: [NSDictionary]?
    var endpoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        networkErrorView.hidden = true

        tableView.dataSource = self
        tableView.delegate = self

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchMovieData", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        fetchMovieData()
    }

    func fetchMovieData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)

                if error != nil {
                    self.networkErrorView.hidden = false
                    self.refreshControl.endRefreshing()
                }

                if let data = dataOrNil {
                    self.networkErrorView.hidden = true

                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
        })
        task.resume()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String

        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURLRequest = NSURLRequest(URL: NSURL(string: baseURL + posterPath)!)
            cell.posterView.setImageWithURLRequest(
                imageURLRequest,
                placeholderImage: UIImage(named: "placeholder"),
                success: { (imageURLRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageURLRequest, imageResponse, error) -> Void in
                    cell.posterView.image = UIImage(named: "placeholder")
                }
            )
        }

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]

        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
}
