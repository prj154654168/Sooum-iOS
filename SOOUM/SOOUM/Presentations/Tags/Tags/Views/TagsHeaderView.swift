//
//  TagsHeaderView.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

class TagsHeaderView: UIView {
    let titlelabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.text = "내가 즐겨찾기한 태그"
    }
}
