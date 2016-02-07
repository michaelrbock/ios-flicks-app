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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var refreshControl: UIRefreshControl!

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        networkErrorView.hidden = true

        tableView.dataSource = self
        tableView.delegate = self

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.hidden = true

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
                        self.filteredMovies = responseDictionary["results"] as? [NSDictionary]
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
        })
        task.resume()
    }

    @IBAction func switchView(sender: UIBarButtonItem) {
        if sender.title == "Grid" {
            tableView.hidden = true
            collectionView.hidden = false
            sender.title = "List"
        } else if sender.title == "List" {
            collectionView.hidden = true
            tableView.hidden = false
            sender.title = "Grid"
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems()
    }

    func numberOfItems() -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableCell", forIndexPath: indexPath) as! MovieTableCell

        setCellInfo(cell, indexPath: indexPath)

        return cell
    }

    func setCellInfo(cell: AnyObject, indexPath: NSIndexPath) {
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String

        let baseURL = "https://image.tmdb.org/t/p/w342"

        if let cell = cell as? MovieTableCell {
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.selectionStyle = .None

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
        } else if let cell = cell as? MovieCollectionCell {
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
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selectionStyle = .None
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell

        setCellInfo(cell, indexPath: indexPath)

        return cell
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        return true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
        collectionView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var indexPath: NSIndexPath?

        if let cell = sender as? UITableViewCell {
            indexPath = tableView.indexPathForCell(cell)
        } else if let cell = sender as? UICollectionViewCell {
            indexPath = collectionView.indexPathForCell(cell)
        }

        let movie = filteredMovies![indexPath!.row]

        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
}
