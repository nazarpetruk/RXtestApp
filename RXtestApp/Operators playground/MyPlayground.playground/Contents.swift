import UIKit
import RxSwift
import RxCocoa

//let strikes = PublishSubject<String>()
//let disposeBag = DisposeBag()
//
//strikes.ignoreElements().subscribe {
//    _ in
//    print("You are out!")
//}.disposed(by: disposeBag)
//
//strikes.onNext("X")
//strikes.onNext("X")
//strikes.onNext("X")
//strikes.onCompleted()


//let strikes = PublishSubject<String>()
//let disposeBag = DisposeBag()
//
//strikes.elementAt(2).subscribe(onNext: {
//    _ in
//    print("You are out!")
//    }).disposed(by: disposeBag)
//
//strikes.onNext("X")
//strikes.onNext("X")
//strikes.onNext("X")

//let disposeBag = DisposeBag()
//
//Observable.of(1,2,3,4,5,6).filter{
//    integer in
//    integer % 2 == 0
//}.subscribe(onNext:{
//    print($0)
//    }).disposed(by: disposeBag)



//let disposeBag = DisposeBag()
//
//Observable.of("A","B","C","D","E","F").skip(3).subscribe(onNext: {
//    print($0)
//    }).disposed(by: disposeBag)


//let disposeBag = DisposeBag()
//Observable.of(2,2,3,4,4).skipWhile {
//    integer in
//    integer % 2 == 0
//}.subscribe(onNext : {
//    print($0)
//    }).disposed(by: disposeBag)


//let disposeBag = DisposeBag()
//
//Observable.of(1,2,3,4,5,6).take(3).subscribe(onNext:{
//    print($0)
//    }).disposed(by: disposeBag)

//let disposeBag = DisposeBag()
//Observable.of(2,2,4,4,6,6).takeWhileWithIndex { integer, index in
//    integer % 2 == 0 && index < 3
//}.subscribe(onNext: {
//    print($0)
//    }).disposed(by: disposeBag)


let disposeBag = DisposeBag()

  let contacts = [
    "603-555-1212": "Florent",
    "212-555-1212": "Junior",
    "408-555-1212": "Marin",
    "617-555-1212": "Scott"
  ]

  func phoneNumber(from inputs: [Int]) -> String {
    var phone = inputs.map(String.init).joined()

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 3)
    )

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 7)
    )

    return phone
  }

  let input = PublishSubject<Int>()

  // Add your code here


  input.onNext(0)
  input.onNext(603)

  input.onNext(2)
  input.onNext(1)

  // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
  input.onNext(7)

  "5551212".forEach {
    if let number = (Int("\($0)")) {
      input.onNext(number)
    }
  }

  input.onNext(9)

