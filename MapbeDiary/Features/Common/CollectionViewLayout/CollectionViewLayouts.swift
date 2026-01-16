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
}

