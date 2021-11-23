//
//  ViewController.swift
//  StoreSearch
//
//  Created by Hayley Robinson on 11/18/21.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }
    var searchResults = [SearchResult]() // fake array for data
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask? // optional because you won’t have a data task until the user performs a search.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()

       tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        
        //  load the nib &ask the table view to register this nib for the reuse identifier “SearchResultCell”.
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(
          cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(
          nibName: TableView.CellIdentifiers.loadingCell,
          bundle: nil)
        tableView.register(
          cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)


    }
    // MARK: - Helper Methods
    
    // builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object.
    func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
          case 1: kind = "musicTrack"
          case 2: kind = "software"
          case 3: kind = "ebook"
          default: kind = ""
        }
      let encodedText = searchText.addingPercentEncoding(
          withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" +
          "term=\(encodedText)&limit=200&entity=\(kind)"

      let url = URL(string: urlString)
      return url!
    }
    //  call to String(contentsOf:encoding:) returns a new string object with the data it receives from the server pointed to by the URL.
    func performStoreRequest(with url: URL) -> Data? {
        do {
        return try Data(contentsOf: url)
        }
        catch {
        print("Download Error: \(error.localizedDescription)")
        showNetworkError() // show an alert box

       return nil
      }
    }
    //  convert the response data from the server to a temporary ResultArray object
    func parse(data: Data) -> [SearchResult] {
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(
          ResultArray.self, from: data)
        return result.results
      } catch {
        print("JSON Error: \(error)")
        return []
      }
    }
    
    // presents an alert controller with an error message.
    func showNetworkError() {
      let alert = UIAlertController(
        title: "Whoops...",
        message: "There was an error accessing the iTunes Store." +
        " Please try again.",
        preferredStyle: .alert)
      
      let action = UIAlertAction(
        title: "OK", style: .default, handler: nil)
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
    }


}
// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    // call the new iTunesURL(searchText:)
    func performSearch() {
      if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()

        dataTask?.cancel() //If there is an active data task, this cancels it,
        isLoading = true
        tableView.reloadData()

        hasSearched = true
        searchResults = []
        // Create the URL object using the search text
        let url = iTunesURL(
          searchText: searchBar.text!,
          category: segmentedControl.selectedSegmentIndex)


        // uses the default configuration with respect to caching, cookies, and other web stuff.
        let session = URLSession.shared

        //  fetches the contents of a given URL. The code from the completion handler will be invoked when the data task has received a response from the server.
        dataTask = session.dataTask(with: url, completionHandler: {data, response, error in
            if let error = error as NSError?, error.code == -999
            {
                return  // Search was cancelled
            }
            else if let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
            {
                if let data = data {
                  self.searchResults = self.parse(data: data)
                  self.searchResults.sort(by: <)
                  DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                  }
                  return // exits the closure after the search results get displayed in the table view
                }
            } else {
                print("Failure! \(response!)")
            }
            // if something went wrong
            DispatchQueue.main.async {
              self.hasSearched = false
              self.isLoading = false
              self.tableView.reloadData() // refreshed to get rid of the Loading…
              self.showNetworkError() // let the user know about the problem
            }
        })
        // once you have created the data task, you need to call resume() to start it. This sends the request to the server on a background thread. So, the app is immediately free to continue — URLSession is as asynchronous as they come.
        dataTask?.resume()
      }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      performSearch()
    }


    // status bar area was unified with the search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }

}
// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched {
          return 0
        } else if searchResults.count == 0 {
          return 1
        } else {
          return searchResults.count
        }
    }
    
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if isLoading {
          let cell = tableView.dequeueReusableCell(
            withIdentifier: TableView.CellIdentifiers.loadingCell,
            for: indexPath)
              
          let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
          spinner.startAnimating()
          return cell
        }
        else if searchResults.count == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      } else
        {
        let cell = tableView.dequeueReusableCell(withIdentifier:
          TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell

        let searchResult = searchResults[indexPath.row]
        cell.configure(for: searchResult)

        return cell
      }
    }


    func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
      
    func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
      if searchResults.count == 0 || isLoading {
        return nil
      } else {
        return indexPath
      }
    }

    
}
