//
//  CalenderMemoView.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/30/24.
//

import UIKit
import SnapKit
import FSCalendar

final class CalenderMemoView: BaseView {
   
    typealias DataSource = UICollectionViewDiffableDataSource<Folder,LocationMemo>
    
    private var dataSource: DataSource?
    
    let calenderView = FSCalendar(frame: .zero)
    
    private let emptyImage: UIImageView = {
        let view = UIImageView(image:  UIImage(named: "emptyFolder"))
        return view
    }()
    
    let collectioView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    let viewModel = CalenderMemoViewModel()
    
    private var isAnimating = false
    

    private var calendarCellRegist: UICollectionView.CellRegistration<CalendarCollectionViewCell,LocationMemo>?

    override func configureHierarchy() {
        addSubview(calenderView)
        addSubview(collectioView)
        addSubview(emptyImage)
        
        settingGesture()
        cellRegistration()
        setDataSource()
        setSnapShot()
        bind()
        
        collectioView.delegate = self
    }

    
    override func configureLayout() {
        calenderView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(400)
        }
        collectioView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(calenderView.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        emptyImage.snp.makeConstraints { make in
            make.center.equalTo(collectioView)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(50)
            make.height.equalTo(emptyImage.snp.width)
        }
    }
    
    override func designView() {
        calendarSetting()
        collectioView.collectionViewLayout = collectionViewSetting()
    }
    
    private func collectionViewSetting() -> UICollectionViewCompositionalLayout{
        return UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            return MordernCollectionViewLayout.createCalendarLayout()
        })
    }
    private func setDataSource(){
        dataSource = DataSource(collectionView: collectioView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = self?.calendarCellRegist else { return .init() }
            return collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func cellRegistration(){
        calendarCellRegist = UICollectionView.CellRegistration<CalendarCollectionViewCell,LocationMemo> { cell, indexPath, item in
            cell.backgroundColor = .wheetBior
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            cell.subscribe(item)
        }
    }
    
    private func setSnapShot(){
        var snapShot = NSDiffableDataSourceSnapshot<Folder,LocationMemo> ()
        
        let section = viewModel.folder.value
        let items = viewModel.locationMemos.value
        
        guard let section else { return }
        guard let items else { return }
        snapShot.appendSections([section])
        snapShot.appendItems(items)
        dataSource?.apply(snapShot)
    }
    
    private func imageHidden(_ bool: Bool){
        emptyImage.isHidden = !bool
    }
    
    private func bind(){
        viewModel.locationMemos.bind { [weak self] date in
            guard let self else { return }
            guard let date else { return }
            imageHidden(date.isEmpty)
            setSnapShot()
        }
    }
   
}
extension CalenderMemoView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectIndexPath.value = indexPath
    }
}


// MARK: 캘린더
extension CalenderMemoView {
    private func settingCalendarLayout(_ gesture: UISwipeGestureRecognizer.Direction) {
        guard !isAnimating else { return }
        isAnimating = true
        
        UIView.animate(withDuration: 0.28) { [weak self] in
            guard let weakself = self else { return }
            if gesture == .up {
                weakself.calenderView.snp.updateConstraints { make in
                    make.height.equalTo(150)
                }
                weakself.collectioView.snp.updateConstraints { make in
                    make.top.equalTo(weakself.calenderView.snp.bottom)
                }
            } else if gesture == .down {
                weakself.calenderView.snp.updateConstraints { make in
                    make.height.equalTo(400)
                }
                weakself.collectioView.snp.updateConstraints { make in
                    make.top.equalTo(weakself.calenderView.snp.bottom)
                }
            }
            weakself.layoutIfNeeded()
        } completion: {[weak self] _ in
            self?.isAnimating = false
        }

        
    }

    private func settingGesture(){
        let swipUp = UISwipeGestureRecognizer(target: self, action: #selector(handlingSwipe))
        swipUp.direction = .up
        
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(handlingSwipe))
        swipDown.direction = .down
        
        calenderView.addGestureRecognizer(swipUp)
        calenderView.addGestureRecognizer(swipDown)
        
    }
    
      @objc
      private func handlingSwipe(_ sender: UISwipeGestureRecognizer) {
        
          if sender.direction == .up {
              print("UP")
              calenderView.setScope(.week, animated: true)
          } else if sender.direction == .down {
              print("Down")
              calenderView.setScope(.month, animated: true)
          }
          settingCalendarLayout(sender.direction)
          sender.isEnabled = true

      }
    
    private func calendarSetting(){
        calenderView.locale = Locale.current
        
        calenderView.scrollEnabled = true
        calenderView.scrollDirection = .horizontal
        
        calenderView.appearance.weekdayFont = .systemFont(ofSize: 14, weight: .semibold)
        calenderView.appearance.weekdayTextColor = .systemPink
        calenderView.appearance.headerTitleFont = .systemFont(ofSize: 18, weight: .semibold)
        calenderView.appearance.headerTitleColor = .systemPink
        
        calenderView.appearance.headerDateFormat = "yyyy.MM"
        calenderView.appearance.headerTitleAlignment = .center
        calenderView.appearance.headerMinimumDissolvedAlpha = 0
         
        calenderView.headerHeight = 45
        
        calenderView.appearance.eventDefaultColor = .green
        calenderView.appearance.eventSelectionColor = .cyan
        
        calenderView.allowsMultipleSelection = false
        calenderView.placeholderType = .none
        
        
    }
    
    
}
