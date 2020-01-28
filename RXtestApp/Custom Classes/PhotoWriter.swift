//
//  PhotoWriter.swift
//  RXtestApp
//
//  Created by Nazar Petruk on 28/01/2020.
//  Copyright © 2020 Nazar Petruk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class PhotoWriter: NSObject {
  typealias Callback = (NSError?)->Void
    private var callback : Callback
    private init(callback : @escaping Callback) {
        self.callback = callback
    }
    
    @objc func image(_ image : UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        callback(error)
    }
    
    static func save(_ image : UIImage) -> Observable<Void>{
        return Observable.create({
            observer in
            let writer = PhotoWriter(callback: {
                error in
                if let error = error {
                    observer.onError(error)
                }else{
                    observer.onCompleted()
                }
            })
            UIImageWriteToSavedPhotosAlbum(image, writer, #selector(PhotoWriter.image(_:didFinishSavingWithError:contextInfo:)), nil)
            return Disposables.create()
        })
    }
}
