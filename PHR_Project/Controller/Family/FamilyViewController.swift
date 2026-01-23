

import UIKit

class FamilyViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource
{

    // MARK: - Outlets

    @IBOutlet weak var collectionView: UICollectionView!

    private var familyData: [FamilyMember] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupCollectionView()
    }

    private func setupData() {
        familyData = FamilyService.shared.getAllMembers()
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false

        // Register cell
        collectionView.register(
            FamilyMemberCell.self,
            forCellWithReuseIdentifier: FamilyMemberCell.identifier
        )

        // Register the Header
        collectionView.register(
            FamilyHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: FamilyHeaderView.identifier
        )

        // Set Delegates
        collectionView.dataSource = self
        collectionView.delegate = self

        // Apply Compositional Layout
        collectionView.collectionViewLayout = createLayout()
    }

    // MARK: - Compositional Layout

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in

            // 0.33 fractional width for 3 columns
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

    // MARK: - DataSource

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

    // MARK: - Header Configuration

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
        // Deselect the item immediately
        collectionView.deselectItem(at: indexPath, animated: true)

        // Get specific member data
        let selectedMember = familyData[indexPath.row]
        performSegue(
            withIdentifier: SegueIdentifiers.goToMemberDetails,
            sender: selectedMember
        )
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
    }
}
