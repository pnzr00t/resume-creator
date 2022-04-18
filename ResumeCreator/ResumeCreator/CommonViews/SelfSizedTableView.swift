//
//  SelfSizedTableView.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 16.04.2022.
//

import RxCocoa
import RxSwift
import UIKit

final class SelfSizedTableView: UITableView {
    private let disposeBag: DisposeBag = .init()
    private var heightConstraint: NSLayoutConstraint?
    fileprivate let heightRelay = BehaviorRelay<CGFloat>(value: 0)

    init() {
        super.init(frame: .zero, style: .plain)

        heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true

        isScrollEnabled = false
        rx.contentSize
            .bind(with: self) { `self`, contentSize in
                self.heightConstraint?.constant = contentSize.height
                self.heightRelay.accept(contentSize.height)
            }
            .disposed(by: disposeBag)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: SelfSizedTableView {
    var contentHeight: ControlEvent<CGFloat> {
        ControlEvent(events: base.heightRelay)
    }
}
