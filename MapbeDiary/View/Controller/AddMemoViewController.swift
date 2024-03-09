//
//  AddMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit

final class AddMemoViewController: BaseHomeViewController<AddBaseView> {
    var addViewModel = AddViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.backgroundColor = .white
    }
}
