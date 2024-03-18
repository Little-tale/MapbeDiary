//
//  AboutLocationViewController.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/13/24.
//
// -> 레이아웃 -> 데이타 소스(타입정하기) 
// -> 레지스트레이션(데이터 반영)(cellFor)  -> 데이타소스에 등록 -> 스냅샷
import UIKit

protocol AboutmodifyLocation: AnyObject {
    func getModifyInfo(with lcation: LocationMemo)
}

class AboutLocationViewController: BaseHomeViewController<LocationAboutMemosView> {
    
    let viewModel = AboutLocationViewModel()
    var disPatchQueItem: DispatchWorkItem?
    weak var backdelegate: BackButtonDelegate?
    weak var locationDelegate: AboutmodifyLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateDataSource()
        settingNotification()
        subscribe()
        locationDelete()
        emmtyButtonAction()
        detailAddButtonAction()
        backButtonAction()
        annotationModifyAction()
    }
    
    func delegateDataSource() {
        homeView.detailTableView.dataSource = self
        homeView.detailTableView.delegate = self
        homeView.detailTableView.rowHeight = UITableView.automaticDimension
        homeView.detailTableView.estimatedRowHeight = 200
    }

    func settingNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataLocation), name: .didSaveActionDetailMemo, object: nil)
    }
}

// MARK: ButtonAction
extension AboutLocationViewController {
    
    func emmtyButtonAction(){
        homeView.memoEmptyView.emptyButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            newDetailMemoAction()
        }), for: .touchUpInside)
        
    }
    func detailAddButtonAction(){
        homeView.detailAddButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            newDetailMemoAction()
        }), for: .touchUpInside)
    }
    
    func locationDelete(){
        homeView.allDeleteButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            showLocationDeleteAlert()
        }), for: .touchUpInside)
    }
    func backButtonAction(){
        homeView.backButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            dismissAction()
        }), for: .touchUpInside)
    }
    func annotationModifyAction(){
        homeView.modiFyLocationButton.addAction(UIAction(handler: { [weak self] _ in  print("여기인가????")
            guard let self else { return }
            print("여기인가????")
            modifyCheckAction()
        }), for: .touchUpInside)
    }
    
}

extension AboutLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.detailTableViewData.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DatailTableViewCell.reusebleIdentifier, for: indexPath) as? DatailTableViewCell else {
            return UITableViewCell()
        }
        let detailData = viewModel.detailTableViewData.value?[indexPath.row]
        cell.detailContents.text = detailData?.detailContents
        cell.imageBool(!(detailData?.imagePaths.isEmpty ?? true))
        cell.detailcollectionView.tag = indexPath.row
        cell.regDateLabel.text = detailData?.regDate.localDate()
        cell.detailcollectionView.dataSource = self
        cell.detailcollectionView.delegate = self
        cell.menuDeleteAction = { [weak self] in
            self?.deleteMemo(indexPath)
        }
        cell.menuModifyAction = { [weak self] in
            self?.modeiFy(indexPath)
        }
        cell.detailcollectionView.reloadData()
        return cell
    }
}

// MARK: Action
extension AboutLocationViewController {
    // 1. 수정시
    func modeiFy(_ indexPath: IndexPath){
        guard let data = viewModel.detailTableViewData.value else {
            print("노 데이타 모디파이")
            return
        }
        let detail = data[indexPath.row]
        guard let loaction = viewModel.inputLocationMemo.value else { return }
        
        let vc = AboutMemoViewController()
        
        vc.homeView.memoViewModel.inputModel.value = AboutMemoModel(inputLoactionInfo: loaction, inputMemoMeodel: detail)
        
        present(vc, animated: true)
    }
    // 메모삭제시
    func deleteMemo(_ indexPath: IndexPath) {
        guard viewModel.detailTableViewData.value != nil else {
            print("노 데이타 딜리트")
            return
        }
        guard viewModel.inputLocationMemo.value != nil else { return }
        showDetailDeleteAlert(indexPath)
    }
    
    func showDetailDeleteAlert(_ indexPath: IndexPath){
        let alert = UIAlertController(title: MapAlertSection.delete.title, message: MapAlertSection.delete.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: MapAlertSection.delete.actionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            viewModel.removeDetailMemo.value = indexPath
        }
        
        let cancel = UIAlertAction(title: MapAlertSection.delete.cancelTitle, style: .default)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    // 로케이션 기록 삭제시
    func showLocationDeleteAlert() {
        let alert = UIAlertController(title: MapAlertSection.delete.title, message: MapAlertSection.delete.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: MapAlertSection.delete.actionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            viewModel.removeLocationMemo.value = ()
        }
        let cancel = UIAlertAction(title: MapAlertSection.delete.cancelTitle, style: .default)
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    // 지역 수정 액션
    func modifyCheckAction(){
        showAlertHandlerCancel(title: "수정", message: "장소를 수정 하러 가시겠습니까?", actionTitle: "이동하기") {[weak self] _ in
            guard let self else { return }
            guard let location = viewModel.inputLocationMemo.value else { return }
            locationDelegate?.getModifyInfo(with: location)
        }
    }
    
    func newDetailMemoAction(){
        guard let location = viewModel.inputLocationMemo.value else {
            print("이때도 에러 처리해야해")
            return
        }
        let vc = AboutMemoViewController()
        vc.homeView.memoViewModel.inputModel.value = AboutMemoModel(inputLoactionInfo: location)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    
    
    @objc
    func reloadDataLocation(){
        viewModel.inputLocationMemo.value = viewModel.inputLocationMemo.value
    }
    
    func dismissAction(){
        backdelegate?.backButtonClicked()
    }
}

extension AboutLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.detailTableViewData.value?[collectionView.tag].imagePaths.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlyImageCollectionViewCell.reusebleIdentifier, for: indexPath) as? OnlyImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.settingImageMode(.scaleAspectFill)
        
        let detail = viewModel.detailTableViewData.value?[collectionView.tag]
        
        let imageData = detail?.imagePaths[indexPath.item]
       
            if let imageData,
               let detail{
                let detailId = detail.id.stringValue
                let iamgeid = imageData.id.stringValue
                cell.loadImage(fromPath: iamgeid, detailId)
        }
        
        return cell
    }
}


extension AboutLocationViewController {
    private func subscribe(){
        viewModel.locationInfoOutPut.bind { [weak self ] model in
            guard let self else { return }
            guard let model else { return }
            homeView.memoAboutBaseView.memoAboutViewModel.infoInput.value = model
        }
        viewModel.emptyHiddenOutPut.bind { [weak self] bool in
            guard let self else { return }
            guard let bool else { return }
            homeView.memoEmptyView.isHidden = bool
            homeView.detailAddButton.isHidden = !bool
        }
        viewModel.detailTableViewData.bind { [weak self] memos in
            guard let self else { return }
            guard memos != nil else { return }
            homeView.detailTableView.reloadData()
        }
        viewModel.fileMangerErrorOutPut.bind { [weak self] error in
            guard let self else { return }
            guard let error else { return }
            
            disPatchQueItem?.cancel()
            
            disPatchQueItem = DispatchWorkItem {
                self.showAPIErrorAlert(file: error)
            }
            if let disPatchQueItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: disPatchQueItem)
            }
        }
        
        viewModel.repositoryErrorOutPut.bind {[weak self] error in
            guard let self else { return }
            guard let error else { return }
            DispatchQueue.main.async {
                self.showAPIErrorAlert(repo: error)
            }
        }
        viewModel.dismissAction.bind { [weak self] void in
            guard let self else { return }
            guard void != nil else { return }
            dismissAction()
            SingleToneDataViewModel.shared.shardFolderOb.value =  SingleToneDataViewModel.shared.shardFolderOb.value
        }
    }
}

/*
 /*
  DispatchQueue.global(qos: .userInitiated).async {
      
      let imageRsult = FileManagers.shard.findDetailImageData(detailID: detailId, imageIds: [iamgeid])
      
      DispatchQueue.main.async {
          switch imageRsult {
          case .success(let success):
              cell.backgoundImage.image = UIImage(data: success[0])?.resizeImage(newWidth: 200)
          case .failure(let failure):
              self.viewModel.fileMangerErrorOutPut.value = failure
          }
      }
  }
  */
 */
/*
 // 로케이션메모가 들어왔다 가정
 let location = viewModel.repository.findFirstLocationMemo()
 viewModel.inputLocationMemo.value = location
 */
