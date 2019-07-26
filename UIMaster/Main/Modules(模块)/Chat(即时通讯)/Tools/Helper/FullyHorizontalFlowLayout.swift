//
//  FullyHorizontalFlowLayout.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class FullyHorizontalFlowLayout: UICollectionViewFlowLayout {
    internal var columns = -1
    internal var rows = -1

    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else {
            return UICollectionViewLayoutAttributes()
        }
        let currentColumns = self.columns != -1 ? self.columns : Int(collectionView.frame.size.width / self.itemSize.width)
        let currentRows = self.rows != -1 ? self.rows : Int(collectionView.frame.size.height / self.itemSize.height)
        let idxPage = indexPath.row / (currentColumns * currentRows)
        let rowNum: Int = indexPath.row - (idxPage * currentColumns * currentRows)
        let rowRemainder = Int(rowNum / currentColumns)
        let second = rowNum % currentColumns
        let totalRowNum: Int = rowRemainder + second * currentRows + idxPage * currentColumns * currentRows
        let fakeIndexPath = IndexPath(item: totalRowNum, section: indexPath.section)
        let attributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: fakeIndexPath)!
        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let newX = min(0, rect.origin.x - rect.size.width / 2)
        let newWidth = rect.size.width * 2 + (rect.origin.x - newX)
        let newRect = CGRect(x: newX, y: rect.origin.y, width: newWidth, height: rect.size.height)

        let attributes = super.layoutAttributesForElements(in: newRect)!
        var attributesCopy = [UICollectionViewLayoutAttributes]()

        for itemAttributes in attributes {
            let itemAttributesCopy = itemAttributes.copy() as? UICollectionViewLayoutAttributes ?? UICollectionViewLayoutAttributes()
            attributesCopy.append(itemAttributesCopy)
        }

        return attributesCopy.map { attr in
            let newAttr: UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: attr.indexPath)
            attr.frame = newAttr.frame
            attr.center = newAttr.center
            attr.bounds = newAttr.bounds
            attr.isHidden = newAttr.isHidden
            attr.size = newAttr.size
            return attr
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override var collectionViewContentSize: CGSize {
        let size = super.collectionViewContentSize
        let collectionViewWidth: CGFloat = self.collectionView!.frame.size.width
        let nbOfScreens = Int(ceil((size.width / collectionViewWidth)))
        let newSize = CGSize(width: collectionViewWidth * CGFloat(nbOfScreens), height: size.height)
        return newSize
    }
}
