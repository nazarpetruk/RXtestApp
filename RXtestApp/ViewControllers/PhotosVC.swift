//
//  PhotosVC.swift
//  RXtestApp
//
//  Created by Nazar Petruk on 28/01/2020.
//  Copyright © 2020 Nazar Petruk. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

private let reuseIdentifier = "Cell"

class PhotosVC: UICollectionViewController {
    
    // MARK: public properties
    let disposeBag2 = DisposeBag()
    
    // MARK: private properties
    private lazy var photos = PhotosVC.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos : Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        let authorized = PHPhotoLibrary.authorized.share()
        authorized
            .skipWhile { $0 == false }
            .take(1)
            .subscribe(onNext: {
                [weak self] _ in
                self?.photos = PhotosVC.loadPhotos()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }).disposed(by: disposeBag2)
        authorized
            .distinctUntilChanged()
            .takeLast(1)
            .filter{ $0 == false }
            .subscribe(onNext: {
                [weak self] _ in
                guard let errorMessage = self?.errorMessage else {return}
                DispatchQueue.main.async(execute: errorMessage)
            })
            .disposed(by: disposeBag2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
        
    }
    
    //MARK: Alerts & Messages
    
    private func errorMessage() {
        alert(title: "No access to Camera Roll", text: "You can grant access from Settings")
            .take(5.0, scheduler: MainScheduler.instance)
            .subscribe(onDisposed : {
                [weak self] in
                self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag2)
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?.selectedPhotosSubject.onNext(image)
            }
        })
    }
}
