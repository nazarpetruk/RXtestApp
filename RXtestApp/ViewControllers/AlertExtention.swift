//
//  AlertExtention.swift
//  RXtestApp
//
//  Created by Nazar Petruk on 28/01/2020.
//  Copyright © 2020 Nazar Petruk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


extension UIViewController {
    func alert(title: String, text: String?) -> Observable<Void>{
        return Observable.create{
            [weak self] observer in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: {
                _ in observer.onCompleted()
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
