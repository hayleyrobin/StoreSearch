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
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
      }
    }


    var searchResults = [SearchResult]() // fake array for data
    var hasSearched = false


    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()

       tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        //  load the nib &ask the table view to register this nib for the reuse identifier “SearchResultCell”.
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(
          cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)

    }
    // MARK: - Helper Methods
    
    // builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object.
    func iTunesURL(searchText: String) -> URL {
      let encodedText = searchText.addingPercentEncoding(
          withAllowedCharacters: CharacterSet.urlQueryAllowed)!
      let urlString = String(
        format: "https://itunes.apple.com/search?term=%@",
        encodedText)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()

        hasSearched = true
        searchResults = []

        let url = iTunesURL(searchText: searchBar.text!)
        print("URL: '\(url)'")
        if let data = performStoreRequest(with: url) {
            searchResults = parse(data: data)
            searchResults.sort { $0 < $1 }

        }
        tableView.reloadData()
      }
    }

    // status bar area was unified with the search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }

}
// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
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
      if searchResults.count == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier:
          TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell

        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
          cell.artistNameLabel.text = "Unknown"
        } else {
          cell.artistNameLabel.text = String(
            format: "%@ (%@)",
            searchResult.artist,
            searchResult.type)
        }

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
      if searchResults.count == 0 {
        return nil
      } else {
        return indexPath
      }
    }

    
}
