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

    var searchResults = [SearchResult]() // fake array for data
    var hasSearched = false


    override func viewDidLoad() {
        super.viewDidLoad()
       tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)

    }


}
// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = [] // instantiate a new String array and replace the contents
        if searchBar.text! != "justin bieber" {
            for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake Result %d for", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
            }
        }
        hasSearched = true
      tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(
          withIdentifier: cellIdentifier)
        if cell == nil {
          cell = UITableViewCell(
            style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        if searchResults.count == 0 {
          cell.textLabel!.text = "(Nothing found)"
          cell.detailTextLabel!.text = ""
        } else {
          let searchResult = searchResults[indexPath.row]
          cell.textLabel!.text = searchResult.name
          cell.detailTextLabel!.text = searchResult.artistName
        }
        return cell
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