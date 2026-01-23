import UIKit

class BrowseTableViewController: UITableViewController, UISearchResultsUpdating
{

    struct Category {
        let name: String
        let icon: String
        let color: UIColor
        let segueIdentifier: String?
    }

    // 1. Data Source
    let categories: [Category] = [
        Category(
            name: "Steps",
            icon: "flame.fill",
            color: .systemOrange,
            segueIdentifier: "stepsSegue"
        ),
        Category(
            name: "Glucose",
            icon: "heart.fill",
            color: .systemRed,
            segueIdentifier: "glucoseSegue"
        ),
        Category(
            name: "Water Intake",
            icon: "drop.fill",
            color: .systemBlue,
            segueIdentifier: "waterSegue"
        ),
        Category(
            name: "Your Family",
            icon: "person.fill",
            color: .systemCyan,
            segueIdentifier: "familySegue"
        ),
        Category(
            name: "Allergy",
            icon: "allergens.fill",
            color: .systemTeal,
            segueIdentifier: "allergySegue"
        ),
        Category(
            name: "Meal Logs",
            icon: "fork.knife.circle",
            color: .systemGreen,
            segueIdentifier: "mealLogsSegue"
        ),
        Category(
            name: "Generate Summary",
            icon: "list.bullet.clipboard.fill",
            color: .systemPurple,
            segueIdentifier: "summarySegue"
        ),
        Category(
            name: "Documents",
            icon: "document.fill",
            color: .systemBlue,
            segueIdentifier: "documentsSegue"
        ),
        Category(
            name: "Symptoms",
            icon: "waveform.path.ecg",
            color: .systemYellow,
            segueIdentifier: "browseSymptomsSegue"
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

        setupSearchController()
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
            withIdentifier: CellIdentifiers.browseCell,
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
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCategory = categories[indexPath.row]
        // Navigate to details controller if segue identifier exists
        if let segueIdentifier = selectedCategory.segueIdentifier {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
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
