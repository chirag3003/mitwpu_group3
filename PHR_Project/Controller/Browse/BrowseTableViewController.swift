//
//  BrowseTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 08/12/25.
//

import UIKit

class BrowseTableViewController: UITableViewController, UISearchResultsUpdating
{

    struct Category {
        let name: String
        let icon: String
        let color: UIColor
    }

    // 1. Data Source
    let categories: [Category] = [
        Category(name: "Activity", icon: "flame.fill", color: .systemOrange),
        Category(name: "Glucose", icon: "heart.fill", color: .systemRed),
        Category(name: "Water Intake", icon: "drop.fill", color: .systemBlue),
        Category(name: "Medications", icon: "pills.fill", color: .systemCyan),
        Category(name: "Allergy", icon: "allergens.fill", color: .systemTeal),
        Category(
            name: "Nutrition",
            icon: "fork.knife.circle",
            color: .systemGreen
        ),
        Category(
            name: "Generate Summary",
            icon: "list.bullet.clipboard.fill",
            color: .systemPurple
        ),
        Category(
            name: "Notifications",
            icon: "lightbulb.max.fill",
            color: .systemBlue
        ),
        Category(
            name: "Symptoms",
            icon: "waveform.path.ecg",
            color: .systemYellow
        ),
    ]

    // Filtered data for search
    var filteredCategories: [Category] = []

    // 2. The Search Controller (Standard Apple UI)
    let searchController = UISearchController(searchResultsController: nil)

    // Helper to check if searching
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Search
        setupSearchController()

        // Setup Keyboard Dismissal (Scroll to hide)
//        tableView.keyboardDismissMode = .interactive
    }

    func setupSearchController() {
        // 1. connect delegate
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"

        // 2. Add to Navigation Item (This puts it in the large title area like Apple Health)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // 3. Prevent the search bar from hiding the Tab Bar
        definesPresentationContext = true
    }

    @objc func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isFiltering {
            return filteredCategories.count
        }
        return categories.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "browse_cell",
            for: indexPath
        )

        let item: Category
        if isFiltering {
            item = filteredCategories[indexPath.row]
        } else {
            item = categories[indexPath.row]
        }

        // Configuration
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
        content.image = UIImage(systemName: item.icon)
        content.imageProperties.tintColor = item.color
        cell.contentConfiguration = content

        return cell
    }

    // MARK: - Search Logic
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }

    func filterContentForSearchText(_ searchText: String) {
        filteredCategories = categories.filter { (category: Category) -> Bool in
            return category.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}
