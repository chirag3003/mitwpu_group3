//
//  DocumentsViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 25/11/25.
//
import UIKit

class DocumentsViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    @IBOutlet weak var documentTableView: UITableView!

    @IBOutlet weak var dataSegment: UISegmentedControl!
    private var documentData: [documentsModel] = []
    private var reportsData: [ReportModel] = []
    
    private func fetchDocumentData() {
        documentData = getAllData().document.prescriptions
    }
    private func fetchReportsData() {
        reportsData = getAllData().document.reports
    }
    private lazy var filterButton: UIButton = {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "line.3.horizontal.decrease")
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            config.baseForegroundColor = .label
            
            // Glass Effect
            config.background.visualEffect = UIBlurEffect(style: .systemThinMaterial)
            config.background.backgroundColor = .systemBackground.withAlphaComponent(0.3)
            config.cornerStyle = .capsule
            
            let button = UIButton(configuration: config, primaryAction: nil)
            
            // Shadow for pop
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            
            button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    var isNewestFirst = true
   

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchDocumentData()
        fetchReportsData()
       

        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
        setupFilterButtonUI()

    }
    private func createSortMenu() -> UIMenu {
            
            
            let newestAction = UIAction(
                title: "Newest First",
                image: UIImage(systemName: "arrow.down"),
                state: isNewestFirst ? .on : .off // Show checkmark if true
            ) { [weak self] _ in
                self?.updateSortOrder(newestFirst: true)
            }
            
            
            let oldestAction = UIAction(
                title: "Oldest First",
                image: UIImage(systemName: "arrow.up"),
                state: !isNewestFirst ? .on : .off // Show checkmark if false
            ) { [weak self] _ in
                self?.updateSortOrder(newestFirst: false)
            }
            
            
            return UIMenu(title: "Sort By", options: .displayInline, children: [newestAction, oldestAction])
        }
    func updateSortOrder(newestFirst: Bool) {
            
            self.isNewestFirst = newestFirst
            
            
            self.sortData()
            
            
            self.filterButton.menu = createSortMenu()
        }
    func setupFilterButtonUI() {
        view.addSubview(filterButton)
        
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        documentTableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            
            filterButton.topAnchor.constraint(equalTo: dataSegment.bottomAnchor, constant: 12),
            
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           
            filterButton.widthAnchor.constraint(equalToConstant: 36),
            filterButton.heightAnchor.constraint(equalToConstant: 36),
            
            
            documentTableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10),
            
          
            documentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            documentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    @objc private func didTapFilterButton() {
            
            isNewestFirst.toggle()
            
            sortData()
            
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            print("Sorting: \(isNewestFirst ? "Newest First" : "Oldest First")")
        }
    func sortData() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
      
        if dataSegment.selectedSegmentIndex == 0 {
            
           
            documentData.sort { (doc1: documentsModel, doc2: documentsModel) -> Bool in
                
               
                let date1 = formatter.date(from: doc1.lastUpdatedAt) ?? Date.distantPast
                let date2 = formatter.date(from: doc2.lastUpdatedAt) ?? Date.distantPast
                
                
                if isNewestFirst {
                    return date1 > date2
                } else {
                    return date1 < date2
                }
            }
            
        } else {
            
            
            reportsData.sort { (rep1: ReportModel, rep2: ReportModel) -> Bool in
                
                let date1 = formatter.date(from: rep1.lastUpdatedAt) ?? Date.distantPast
                let date2 = formatter.date(from: rep2.lastUpdatedAt) ?? Date.distantPast
                
                if isNewestFirst {
                    return date1 > date2
                } else {
                    return date1 < date2
                }
            }
        }
        
        
        documentTableView.reloadData()
    }
    @objc private func dateSelectionChanged(_ sender: UIDatePicker) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            filterButton.configuration?.title = formatter.string(from: sender.date)
           
        }
    
    
    
    
    @IBAction func onDataSwitch(_ sender: Any) {
        documentTableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
       
        return DefaultValues.defaultTableRowHeight
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        if(dataSegment.selectedSegmentIndex == 0){
            return documentData.count
        }
        return reportsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if(dataSegment.selectedSegmentIndex == 0){
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.doctorCell,
                for: indexPath
            ) as! DocumentTableViewCell
            let doctor = documentData[indexPath.row]
            cell.selectionStyle = .none
            cell.configure(with: doctor)
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.reportCell, for: indexPath) as! ReportsTableViewCell
        let report = reportsData[indexPath.row]
        cell.configure(with: report)
        cell.selectionStyle = .none
        return cell
    }

}

