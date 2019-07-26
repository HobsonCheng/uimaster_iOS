//
//  GoodsListVC.swift
//  UIMaster
//
//  Created by 希德梅尔 on 2019/7/16.
//  Copyright © 2019 one2much. All rights reserved.
//

import Foundation
import SnapKit
import MJRefresh

class GoodsListVC: BaseNameVC, PageModuleAble {
    private var pageNum: Int = 1
    /// 样式
    var styleDic: [String: Any]?
    /// 参数
    var moduleParams: [String: Any]?
    /// 代理
    weak var moduleDelegate: ModuleRefreshDelegate?

    var datasource = [
    ["normalIcon": "1", "title": "阿迪达斯官方旗舰店 adidas FreeLift Prime 男子训练半袖你值得拥有", "price": "￥99.00", "time": "10人付款"],
    ["normalIcon": "1", "title": "阿迪达斯官方旗舰店 adidas FreeLift Prime 男子训练半袖你值得拥有", "price": "￥99.00", "time": "10人付款"],
    ["normalIcon": "1", "title": "阿迪达斯官方旗舰店 adidas FreeLift Prime 男子训练半袖你值得拥有", "price": "￥99.00", "time": "10人付款"],
    ["normalIcon": "1", "title": "阿迪达斯官方旗舰店 adidas FreeLift Prime 男子训练半袖你值得拥有", "price": "￥99.00", "time": "10人付款"],
    ["normalIcon": "1", "title": "阿迪达斯官方旗舰店 adidas FreeLift Prime 男子训练半袖你值得拥有", "price": "￥99.00", "time": "10人付款"],
    ]

    lazy var goodsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width / 2 - 10, height: 250)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 5, bottom: 10, right: 5)
        // 设置分区头视图和尾视图宽高
        layout.headerReferenceSize = CGSize.init(width: view.bounds.width, height: 30)
        layout.footerReferenceSize = CGSize.init(width: view.bounds.width, height: 30)
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1300), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.init(hexString: "#E3E3E3")
        view.addSubview(collectionView)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        goodsCollectionView.register(GoodsListCell.self, forCellWithReuseIdentifier: GoodsListCell.getIdentifier)
        getGoodsListData()
        loadMoreData(collectionView: goodsCollectionView)
        reloadViewData(collectionView: goodsCollectionView)
//        self.listTableView.register(FriendApplyCell.getNib(), forCellReuseIdentifier: FriendApplyCell.getIdentifier)
        //        DatabaseTool.shared.modifyNotificationReceiptState(database: nil, action: .applyForFriend, state: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension GoodsListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsListCell.getIdentifier, for: indexPath) as? GoodsListCell
        if cell == nil {
            cell = GoodsListCell.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width / 2 - 10, height: 250))
        }
        cell?.rederGoodsCell(cellStyle: datasource[indexPath.row])
        cell?.backgroundColor = UIColor.white
        return cell ?? GoodsListCell()
    }
}

extension GoodsListVC {
    func getGoodsListData() {
        NetworkUtil.request(
            target: NetworkService.selectGoodsAppletList(pageIndex: self.pageNum, pageContext: 10, goodsName: "", sort: 0),
            success: { [weak self] json in
                
            }
        ) { error in
            dPrint(error)
        }
    }
}

extension GoodsListVC {
    //实现下拉刷新
    func reloadViewData(collectionView: UICollectionView) {
        let header = MJRefreshNormalHeader {[weak self] in
            self?.pageNum = 1
            self?.getGoodsListData()
        }
        collectionView.mj_header = header
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("松开刷新", for: .pulling)
        header?.setTitle("正在刷新", for: .refreshing)
    }
    //实现上拉加载更多
    func loadMoreData(collectionView: UICollectionView) {
        let footer = MJRefreshAutoNormalFooter{[weak self] in
            self?.pageNum += 1
            self?.getGoodsListData()
        }
        footer?.setTitle("点击或上拉加载更多", for: .idle)
        footer?.setTitle("松开加载更多", for: .pulling)
        footer?.setTitle("加载中", for: .refreshing)
        footer?.setTitle("暂无更多数据", for: .noMoreData)
    }
}
