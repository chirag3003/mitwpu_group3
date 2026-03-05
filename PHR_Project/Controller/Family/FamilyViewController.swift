import UIKit

class FamilyViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource
{

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    private var familyData: [FamilyMember] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupCollectionView()
        setupAddMenu()
    }

    private func setupData() {
        familyData = FamilyService.shared.getAllMembers()
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
            if let destinationVC = segue.destination
                as? FamilySwitchTableViewController
            {

                // Set up the half-modal presentation (iOS 15+)
                if let sheet = destinationVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 24
                }
            }
        }
    }
}
