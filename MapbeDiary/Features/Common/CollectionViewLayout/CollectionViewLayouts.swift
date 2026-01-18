//
//  CollectionViewLayouts.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 1/12/26.
//

import UIKit

struct CollectionViewLayouts {
    
    static func makeListLayout(
        separators: Bool = true,
        backgroundColor: UIColor = .white,
        layout: UICollectionLayoutListConfiguration.Appearance = .plain,
    ) -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: layout)
        
        config.showsSeparators = separators
        config.backgroundColor = backgroundColor
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        return layout
    }
    
    
    static func createCalendarBottomCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 0
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    static func makeMemoImagesLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        let spacing : CGFloat = 10
        let cellWidth = UIScreen.main.bounds.width - (spacing * 3)
        
        // 아이템 크기
        layout.itemSize = CGSize(
            width: cellWidth / 3.5,
            height: (cellWidth) / 3.5
        )
        
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        layout.minimumLineSpacing = 20
        
        layout.scrollDirection = .horizontal
        return layout
    }
    
    static func makeImageCarouselSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(140)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    static func makeFullHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(52)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    static func makeFullFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(1)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
    }
    
    static func makeImageCarouselSection(
        hasImages: Bool,
        showsSeparator: Bool = false
    ) -> NSCollectionLayoutSection {
        // 공통 헤더
        let header = makeFullHeader()
        let footer = makeFullFooter()
        let boundaryItems = showsSeparator ? [header, footer] : [header]

        // 이미지X 헤더만 보이게
        if !hasImages {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(1),
                heightDimension: .absolute(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(1)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = boundaryItems
            section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }

        // 이미지 있을 때
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(140)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = boundaryItems
        section.orthogonalScrollingBehavior = .paging
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}
