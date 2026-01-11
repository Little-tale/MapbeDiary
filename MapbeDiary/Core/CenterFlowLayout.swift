//
//  CenterFlowLayout.swift
//  MapbeDiary
//
//  Created by Jae hyung Kim on 3/17/24.
//

import UIKit


final class CenterFlowLayout: UICollectionViewFlowLayout {
    // MARK: 스크롤 동작이 완료 될때 contentOffSet을 결정
    // proposedContentOffset -> 스크롤 동작이 끝날때 나온 값
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // 컬렉션뷰가 없다면 기본동작으로
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        // 컬렉션뷰 현재 바운드를 가져오고
        let collectionViewBounds = collectionView.bounds
        // 컬렉션뷰 위드를 절반으로하고
        let harfW = collectionViewBounds.size.width * 0.5
        // 오프셋 중앙위치를 계산
        let contentOffsetX = proposedContentOffset.x + harfW
        
        // 현재 collectionView CGRect 영역 모든 레이아웃 속성 가져오기
        let layoutAtr = layoutAttributesForElements(in: collectionViewBounds)
        // 임시변수
        var tempAtrr: UICollectionViewLayoutAttributes?
        
        if let layoutAtr{
            // 모든 영역 즉 헤더, 푸터 등이 있어서 그중 셀만 처리할수 있게 한다.
            for attri in layoutAtr {
                if attri.representedElementCategory != .cell {
                    continue
                }
                
                // 첫번째 셀인경우 후보로 등록
                if tempAtrr == nil {
                    tempAtrr = attri
                    continue
                }
                
                let first = attri.center.x - contentOffsetX
                let second = tempAtrr!.center.x - contentOffsetX
                // 절대값으로 변환 후 비교
                if abs(first) < abs(second){
                    tempAtrr = attri
                }
            }  // 이부분도 꼭 회고!
            return CGPoint(x: (tempAtrr?.center.x ?? 0) - harfW, y: proposedContentOffset.y)
        } else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
    }
}
