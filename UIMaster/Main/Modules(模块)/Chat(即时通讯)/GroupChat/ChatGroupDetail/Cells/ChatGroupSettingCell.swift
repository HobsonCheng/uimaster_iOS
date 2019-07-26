//
//  ChatGroupSettingCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/22.
//  Copyright © 2018 one2much. All rights reserved.
//

import SnapKit
import UIKit

@objc protocol ChatGroupSettingCellDelegate: NSObjectProtocol {
    func clickMoreButton(clickButton button: UIButton)
    func clickAddCell(cell: ChatGroupSettingCell)
    func clickRemoveCell(cell: ChatGroupSettingCell)
    func didSelectCell(cell: ChatGroupSettingCell, indexPath: IndexPath)
}

class ChatGroupSettingCell: UITableViewCell {
    weak var delegate: ChatGroupSettingCellDelegate?

    /// 展示更多按钮
    fileprivate lazy var moreButton = UIButton()
    /// 有几行
    fileprivate var sectionCount = 0
    /// colectionView高度约束，展开列表时需要
    fileprivate var collectionHeightConstraint: Constraint?
    fileprivate var currentUserCount = 0
    fileprivate var isMyGroup = false
    var isExpand: Bool = false

    var memberInfoArr: [ChatGroupMemberData]? {
        didSet {
            self.collectionView.snp.removeConstraints()
            setupUI()
            self.collectionView.reloadData()
            getUserInfoArr()
        }
    }
    /// 详细个人信息
    lazy var memberDetailArr = [UserInfoData]()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(collectionView)
        moreButton.addTarget(self, action: #selector(clickMore), for: .touchUpInside)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        moreButton.setTitle("查看更多 >", for: .normal)
        moreButton.setTitleColor(.gray, for: .normal)
        self.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(26)
            make.bottom.equalTo(-14)
        }
        moreButton.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }()
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChatGroupMemberCell.self, forCellWithReuseIdentifier: ChatGroupMemberCell.getIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizesSubviews = false
        return collectionView
    }()

    fileprivate func setupUI() {
        //1. 计算个数
        self.calSectionCount()
        //2. 是否需要更多按钮
        let totalCount = memberInfoArr?.count ?? 0
        if totalCount > 14 {
            self.moreButton.isHidden = false
        } else {
            self.moreButton.isHidden = true
        }
        //3.计算collectionView的高度
        var collectionHeight: CGFloat
        if isMyGroup {
            if totalCount > 8 {
                collectionHeight = 260
            } else if totalCount > 3 {
                collectionHeight = 200
            } else {
                collectionHeight = 100
            }
        } else {
            if totalCount > 9 {
                collectionHeight = 260
            } else if totalCount > 4 {
                collectionHeight = 200
            } else {
                collectionHeight = 100
            }
        }
        moreButton.isHidden = !self.isExpand
        if isExpand {
            let row = totalCount / 5 + (totalCount % 5 > 0 ? 1 : 0)
            sectionCount = row
            collectionHeight = CGFloat(row * 90)
        }

        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview()
            collectionHeightConstraint = make.height.equalTo(collectionHeight).constraint
        }
    }

    @objc func clickMore() {
        self.isExpand = true
        delegate?.clickMoreButton(clickButton: moreButton)
    }

    func getUserInfoArr() {
        for member in memberInfoArr ?? [] {
            guard let uid = member.uid, let pid = member.user_pid else {
                self.memberDetailArr.append(UserInfoData())
                continue
            }
            DatabaseTool.shared.queryContactsInfo(uid: uid, pid: pid, finish: { [weak self] user in
                if let safeUser = user, !(safeUser.head_portrait?.isEmpty ?? true), let name = safeUser.zh_name, !name.isEmpty {
                    self?.memberDetailArr.append(safeUser)
                } else {
                    let defaultUser = UserInfoData()
                    defaultUser.uid = uid
                    defaultUser.pid = pid
                    self?.memberDetailArr.append(defaultUser)
                    NetworkUtil.request(
                        target: .getInfo(user_id: uid, user_pid: pid),
                        success: { [weak self] json in
                            guard let memberArr = self?.memberDetailArr else {
                                return
                            }
                            let info = UserInfoModel.deserialize(from: json)?.data
                            guard let uid = info?.uid, let pid = info?.pid else {
                                return
                            }
                            if uid == 0 && pid == 0 {
                                return
                            }
                            for (index, userInfo) in memberArr.enumerated() {
                                if userInfo.uid == info?.uid && userInfo.pid == info?.pid {
                                    self?.memberDetailArr[index] = info ?? UserInfoData()
                                    self?.collectionView.reloadItems(at: [IndexPath(row: index % 5, section: index / 5)])
                                }
                            }
                            DatabaseTool.shared.insertContacts(uid: uid, pid: pid, avatar: info?.head_portrait ?? "", nickname: info?.zh_name ?? "", type: 0, message: nil)
                        }
                    ) { error in
                        dPrint(error)
                    }
                }
                if self?.memberInfoArr?.count == self?.memberDetailArr.count {
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                }
            })
        }
    }

    /// 计算个数
    fileprivate func calSectionCount() {
        let totalCount = memberInfoArr?.count ?? 0

        if self.isMyGroup {
            if totalCount > 13 {
                self.currentUserCount = 13
            }
            if totalCount > 8 {
                self.sectionCount = 3
            } else if totalCount > 3 {
                self.sectionCount = 2
            } else {
                self.sectionCount = 1
            }
        } else {
            if totalCount > 14 {
                self.currentUserCount = 14
            }
            if totalCount > 9 {
                self.sectionCount = 3
            } else if totalCount > 4 {
                self.sectionCount = 2
            } else {
                self.sectionCount = 1
            }
        }
    }

//    func updateUserAvatar(){
//        self.getUserInfoArr(finish: { (userInfoArr) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//                if userInfoArr.count < self?.memberInfoArr?.count{
//                    self?.maxRequestTime -= 1
//                    self?.collectionView.snp.removeConstraints()
//                    self?.removeAllSubviews()
//                    self?.setupUI()
//                    self?.collectionView.reloadData()
//                    self?.updateUserAvatar()
//                }
//            }
//        })
//    }

}

extension ChatGroupSettingCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.memberInfoArr?.count ?? 0
        return count >= (section + 1) * 5 ? 5 : count % 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.size.width / 5), height: Int(collectionView.frame.size.height / CGFloat(sectionCount)))
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ChatGroupMemberCell.getIdentifier, for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ChatGroupMemberCell else {
            return
        }
        guard memberDetailArr.count > indexPath.section * 5 + indexPath.row else {
            return
        }
        cell.userInfo = memberDetailArr[indexPath.section * 5 + indexPath.row]
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCell(cell: self, indexPath: indexPath)
    }
}
