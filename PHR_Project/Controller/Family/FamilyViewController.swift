import UIKit

class FamilyViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource
{

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    private var familyData: [FamilyMember] = []
    private var currentFamily: Family?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        collectionView.backgroundColor = .clear

        setupCollectionView()
        setupAddMenu()
        setupObservers()
        refreshFamilies()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupData() {
        currentFamily = FamilyService.shared.getCurrentFamily()
        familyData = FamilyService.shared.getMembersForCurrentFamily()
        navigationItem.title = currentFamily?.name ?? "Family"
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFamiliesUpdated),
            name: NSNotification.Name(NotificationNames.familiesUpdated),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMembersUpdated),
            name: NSNotification.Name(NotificationNames.familyMembersUpdated),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFamilySelectionChanged),
            name: NSNotification.Name(NotificationNames.familySelectionUpdated),
            object: nil
        )
    }

    private func refreshFamilies() {
        FamilyService.shared.fetchFamilies { [weak self] success in
            guard let self = self else { return }
            self.setupData()
            self.collectionView.reloadData()
            if success, let familyId = FamilyService.shared.getCurrentFamilyId() {
                FamilyService.shared.fetchFamilyMembers(familyId: familyId) { _ in
                    self.setupData()
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .clear

        collectionView.register(
            FamilyMemberCell.self,
            forCellWithReuseIdentifier: FamilyMemberCell.identifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.collectionViewLayout = createLayout()
    }

    private func setupAddMenu() {
        let addMemberAction = UIAction(
            title: "Add Member to current Family",
            image: UIImage(systemName: "person.badge.plus")
        ) { [weak self] _ in
            if FamilyService.shared.getCurrentFamilyId() == nil {
                self?.showAlert(
                    title: "No Family",
                    message: "Create a family first to add members."
                )
                return
            }
            self?.performSegue(withIdentifier: "GoToAddMember", sender: nil)
        }

        let createFamilyAction = UIAction(
            title: "Create new Family",
            image: UIImage(systemName: "person.2.fill")
        ) { [weak self] _ in
            self?.performSegue(withIdentifier: "GoToAddFamily", sender: nil)
        }

        let menu = UIMenu(children: [addMemberAction, createFamilyAction])

        addButton.menu = menu
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(66)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [itemSize]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 20,
                leading: 16,
                bottom: 20,
                trailing: 16
            )
            section.interGroupSpacing = 0 

            return section
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return familyData.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FamilyMemberCell.identifier,
                for: indexPath
            ) as? FamilyMemberCell
        else {
            return UICollectionViewCell()
        }

        let member = familyData[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == familyData.count - 1
        cell.configure(with: member, isFirst: isFirst, isLast: isLast)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let selectedMember = familyData[indexPath.row]
        performSegue(
            withIdentifier: SegueIdentifiers.goToMemberDetails,
            sender: selectedMember
        )
    }

    // MARK: - Actions

    @IBAction func familySwitchButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "familySwitchSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.goToMemberDetails {
            if let destinationVC = segue.destination
                as? FamilyMemberViewController
            {
                let selectedMember = sender as? FamilyMember
                destinationVC.familyMember = selectedMember
            }
        }

        if segue.identifier == "familySwitchSegue" {
            if let destinationVC = segue.destination as? FamilySwitchTableViewController {
                if let sheet = destinationVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true 
                    sheet.preferredCornerRadius = 24
                }
            }
        }
    }

    @objc private func handleFamiliesUpdated() {
        setupData()
        collectionView.reloadData()
    }

    @objc private func handleMembersUpdated() {
        setupData()
        collectionView.reloadData()
    }

    @objc private func handleFamilySelectionChanged() {
        setupData()
        collectionView.reloadData()
        if let familyId = FamilyService.shared.getCurrentFamilyId() {
            FamilyService.shared.fetchFamilyMembers(familyId: familyId, completion: nil)
        }
    }
}
