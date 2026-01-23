//
//  FamilyViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 24/11/25.
//

import UIKit

class FamilyViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource
{

    @IBOutlet weak var collectionView: UICollectionView!

    private var familyData: [FamilyMember] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupCollectionView()
    }

    private func setupData() {
        // Mock Data based on your screenshot
        familyData = getAllData().family.members
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        // 1. Register Code-based Views
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

        // 2. Set Delegates
        collectionView.dataSource = self
        collectionView.delegate = self

        // 3. Apply Compositional Layout
        collectionView.collectionViewLayout = createLayout()
    }

    // MARK: - Compositional Layout
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, env) -> NSCollectionLayoutSection? in

            // 1. Item
            // 0.33 fractional width = 3 columns
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

    // MARK: - Header Config
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

            // Add target for the button if needed
            //                header.addButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)

            return header
        }
        return UICollectionReusableView()
    }

    // Add this inside FamilyViewController

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // 1. Deselect the item immediately (standard iOS behavior)
        collectionView.deselectItem(at: indexPath, animated: true)

        // 2. Get the specific member data
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
