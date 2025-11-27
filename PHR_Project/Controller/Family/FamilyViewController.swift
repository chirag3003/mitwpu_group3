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
        familyData = [
            FamilyMember(name: "Dad", imageName: "person.fill", isMe: true),
            FamilyMember(name: "Mom", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Ved", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Sushi", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Chintu", imageName: "person.fill", isMe: false),
            FamilyMember(name: "Tosh", imageName: "person.fill", isMe: false),
        ]
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
                    widthDimension: .fractionalWidth(1.0 / 3.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            itemSize.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )

            // 2. Group
            // Absolute height 150 ensures enough space for Circle + Text
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(150)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [itemSize]
            )

            // 3. Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 16,
                bottom: 20,
                trailing: 16
            )
            section.interGroupSpacing = 10

            // 4. Header Setup
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(220)
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
        print("Tapped on: \(selectedMember.name)")

        // 3. Perform Action (e.g., Navigate to details)
        // Example: Pushing a detail controller
        /*
        let detailVC = MemberDetailViewController()
        detailVC.member = selectedMember
        navigationController?.pushViewController(detailVC, animated: true)
        */

        // For testing now: Show an alert
//        let alert = UIAlertController(
//            title: "Selected",
//            message: "You clicked on \(selectedMember.name)",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)

        performSegue(withIdentifier: "goToMemberDetails", sender: selectedMember)
    }

   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMemberDetails" {
            if let destinationVC = segue.destination
                as? FamilyMemberViewController
            {
                let selectedMember = sender as? FamilyMember
                destinationVC.familyMember = selectedMember
            }
        }
    }
}
