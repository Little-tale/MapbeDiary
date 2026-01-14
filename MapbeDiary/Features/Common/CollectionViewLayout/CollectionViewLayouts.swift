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
}

