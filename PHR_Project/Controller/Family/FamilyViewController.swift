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

        collectionView.register(
            FamilyMemberCell.self,
            forCellWithReuseIdentifier: FamilyMemberCell.identifier
        )

        collectionView.register(
            FamilyHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: FamilyHeaderView.identifier
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
                    widthDimension: .fractionalWidth(
                        UIConstants.CollectionLayout.oneThirdWidth
                    ),
                    heightDimension: .fractionalHeight(
                        UIConstants.CollectionLayout.fullWidth
                    )
                )
            )
            itemSize.contentInsets = NSDirectionalEdgeInsets(
                top: UIConstants.Spacing.small,
                leading: UIConstants.Spacing.small,
                bottom: UIConstants.Spacing.small,
                trailing: UIConstants.Spacing.small
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    UIConstants.CollectionLayout.fullWidth
                ),
                heightDimension: .absolute(
                    UIConstants.CollectionLayout.memberItemHeight
                )
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [itemSize]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: UIConstants.Padding.medium,
                leading: UIConstants.Spacing.medium,
                bottom: UIConstants.Spacing.large,
                trailing: UIConstants.Spacing.medium
            )
            section.interGroupSpacing = UIConstants.Spacing.medium

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(
                    UIConstants.CollectionLayout.fullWidth
                ),
                heightDimension: .estimated(
                    UIConstants.CollectionLayout.headerHeight
                )
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

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
        cell.configure(with: member)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            guard
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: FamilyHeaderView.identifier,
                    for: indexPath
                ) as? FamilyHeaderView
            else {
                return UICollectionReusableView()
            }

            return header
        }
        return UICollectionReusableView()
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
                        // Replace 'ChooseFamilyViewController' with whatever you named your target VC
                        if let destinationVC = segue.destination as? FamilySwitchTableViewController {
                            
                            // Set up the half-modal presentation (iOS 15+)
                            if let sheet = destinationVC.sheetPresentationController {
                                // .medium() gives the half-screen look, .large() allows it to be pulled up to full screen
                                sheet.detents = [.medium(), .large()]
                                sheet.prefersGrabberVisible = true // Shows the little handle at the top
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
