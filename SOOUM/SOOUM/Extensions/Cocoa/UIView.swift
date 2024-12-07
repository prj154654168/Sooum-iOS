//
//  UIView.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
    
    /// 현재 뷰가 탭 제스처에 직접 탭되었는지 확인
    ///
    /// `hitTest(_:with:)`를 사용하여 탭 위치에 있는 가장 앞의 뷰를 찾고, 현재 뷰(`self`)와 동일한지 비교.
    ///
    /// - Returns: 현재 뷰가 직접 탭된 경우 true, 그렇지 않으면 (서브뷰가 탭된 경우) false.
    ///
    /// ## 예시
    ///
    /// ``` swift
    /// viewA.rx.tapGesture()
    ///     .when(.recognized)
    ///     .subscribe(onNext: { gesture in
    ///         // 내부 요소가 탭되었을 때는 조건 실행 X
    ///         if self.viewA.isTappedDirectly(gesture: gesture) {
    ///             print("viewA tapped"
    ///         }
    ///     })
    ///     .disposed(by: disposeBag)
    /// ```
    func isTappedDirectly(gesture: UITapGestureRecognizer) -> Bool {
        let location = gesture.location(in: self)
        let hitView = self.hitTest(location, with: nil)
        return hitView == self
    }
    
    // Set shadow
    func setShadow(
        radius cornerRadius: CGFloat,
        color shadowColor: UIColor,
        blur shadowRadius: CGFloat,
        offset shadowOffset: CGSize
    ) {
        
        // 그림자 렌더링 최적화
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        self.layer.shadowColor = shadowColor.cgColor
        /// Opacity는 1로 설정하여 alpha에 의존
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
    }
}
