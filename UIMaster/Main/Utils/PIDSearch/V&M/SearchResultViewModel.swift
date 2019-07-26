//
//  SearchResultViewModel.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Differentiator
import NSObject_Rx
import RxCocoa
import RxSwift
import RxSwift

class SearchResultViewModel: NSObject {
    //创建监听对象
    var searchList = Variable([SectionModel<String, Project>]())

    let searchUseable: Driver<String>

    init(searchBar: UITextField) {
        let searchDriver = searchBar.rx.text.orEmpty.asDriver()

        searchUseable = searchDriver.flatMapLatest { status in
            Observable.just(status).asDriver(onErrorJustReturn: "error")
        }
    }

    func getSearchEnd(loadMode: Bool, pIndex: Int, pNum: Int, key: String, callback: @escaping (_ noMove: Bool) -> Void) {
        NetworkUtil.request(target: .searchProject(page_index: pIndex, key: key, page_context: pNum), success: { [weak self] json in
            let search = SearchModel.deserialize(from: json)

            var list = search?.data.data_list
            if loadMode {
                let mylist = self?.searchList.value[0].items

                list = mylist! + list!
            }

            let section = [SectionModel(model: "", items: (list)!)]

            self?.searchList.value = section

            if search?.data.data_list.count == search?.data.total {
                callback(true)
            } else {
                callback(false)
            }
        }) { error in
            dPrint(error)
        }
    }
}
