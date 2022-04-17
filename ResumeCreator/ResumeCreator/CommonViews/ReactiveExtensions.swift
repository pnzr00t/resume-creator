//
//  ReactiveExtensions.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 16.04.2022.
//

import RxCocoa
import RxSwift


extension Reactive where Base: UIScrollView {
    var contentSize: ControlEvent<CGSize> {
        let events = observe(CGSize.self, #keyPath(UIScrollView.contentSize))
            .compactMap { $0 }
        return ControlEvent(events: events)
    }
}

extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }

    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }

    var viewDidAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidAppear))
    }

    var viewWillDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillDisappear))
    }

    var viewDidDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidDisappear))
    }
}


extension SharedSequence {
    func take(_ count: Int) -> SharedSequence<SharingStrategy, Element> {
        asObservable().take(count).asSharedSequence(
            sharingStrategy: SharingStrategy.self,
            onErrorDriveWith: SharedSequence<SharingStrategy, Element>.empty()
        )
    }
}
