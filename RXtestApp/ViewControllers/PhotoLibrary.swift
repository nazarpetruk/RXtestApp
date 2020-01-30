//
//  PhotoLibrary.swift
//  RXtestApp
//
//  Created by Nazar Petruk on 30/01/2020.
//  Copyright © 2020 Nazar Petruk. All rights reserved.
//

import Foundation
import Photos
import RxSwift


extension PHPhotoLibrary {
    static var authorized: Observable<Bool> {
        return Observable.create {
            observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                }else{
                    observer.onNext(false)
                    requestAuthorization { newStatus in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
