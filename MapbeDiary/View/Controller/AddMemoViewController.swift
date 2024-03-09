//
//  AddMemoViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/8/24.
//

import UIKit

protocol BackButtonDelegate: AnyObject {
    func backButtonClicked()
}

final class AddMemoViewController: BaseHomeViewController<AddBaseView>{
    var addViewModel = AddViewModel()
    
    // delegate
    weak var backDelegate: BackButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.backgroundColor = .white
        subscribe()
        navigationSetting()
    }
    func navigationSetting(){
        let saveButton = CustomButton.saveCreate(title: AddViewSection.saveButtonText, target: self, action: #selector(saveButtonClicked))
        let dismisButton = CustomButton.backCreate(target: self, action: #selector(backButtonClicked))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = dismisButton
    }
    @objc
    func saveButtonClicked(){
        print(#function)
        addViewModel.saveButtonTrigger.value = ()
    }
    deinit {
        print("deinit",#function)
    }
}

extension AddMemoViewController {
    private func subscribe() {
        addViewModel.urlSuccessOutPut.bind { [weak self] sussesModel in
            guard let self else {return}
            guard let sussesModel else {return}
            homeView.AddTitleDateView.titleTextField.placeholder = sussesModel.titlePlacHolder
            homeView.folderButton.configuration?.title = sussesModel.folder.folderName
            print("@@",sussesModel.folder.folderName)
        }
        addViewModel.urlErrorOutPut.bind { [weak self] error in
            guard let error else { return }
            guard let self else { return }
            showAPIErrorAlert(urlError: error)
        }
        
        addViewModel.realmError.bind { [weak self] error in
            guard let error else { return }
            guard let self else { return }
            showAPIErrorAlert(repo: error)
        }
    }
}

extension AddMemoViewController {
    @objc
    func backButtonClicked() {
        // ismiss(animated: true)
        backDelegate?.backButtonClicked()
    }
}
