//
//  UltravisualLayout.swift
//  ExpandingCollectionView
//
//  Created by Vamshi Krishna on 30/04/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import Foundation
import UIKit

/* The heights are declared as constants outside of the class so they can be easily referenced elsewhere */
struct UltravisualLayoutConstants {
    struct Cell {
        /* The height of the non-featured cell */
        static let standardHeight: CGFloat = 120
        /* The height of the first visible cell */
        static let featuredHeight: CGFloat = 340
    }
}

class UltravisualLayout:UICollectionViewLayout{
    
    // MARK: Properties and Variables
	
	/* The amount the user needs to scroll before the featured cell changes */
	let dragOffset: CGFloat = 180.0
	
	let positionOffset: CGFloat = UltravisualLayoutConstants.Cell.standardHeight
	let highlightPositionIndex: CGFloat = 2.0
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    /* Returns the item index of the currently featured cell */
    var featuredItemIndex: Int {
        get {
            /* Use max to make sure the featureItemIndex is never < 0 */
            return max(0, Int((collectionView!.contentOffset.y + (positionOffset * highlightPositionIndex)) / dragOffset))
        }
    }
    
    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    var nextItemPercentageOffset: CGFloat {
        get {
            return ((collectionView!.contentOffset.y + (positionOffset * highlightPositionIndex)) / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
	
	/* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
	var previousItemPercentageOffset: CGFloat {
		get {
			return 1 - (((collectionView!.contentOffset.y + (positionOffset * highlightPositionIndex)) / dragOffset) - CGFloat(featuredItemIndex))
		}
	}
	
    /* Returns the width of the collection view */
    var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    /* Returns the height of the collection view */
    var height: CGFloat {
        get {
            return collectionView!.bounds.height
        }
    }
    
    /* Returns the number of items in the collection view */
    var numberOfItems: Int {
        get {
            return collectionView!.numberOfItems(inSection: 0)
        }
    }
    
    // MARK: UICollectionViewLayout
    
    /* Return the size of all the content in the collection view */
    
    override var collectionViewContentSize: CGSize{
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
	
	
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
		
        var y: CGFloat = positionOffset * highlightPositionIndex
		var frame = CGRect.zero
		var topPosition: CGFloat = positionOffset * CGFloat(highlightPositionIndex - 1)
		
        for item in 0..<numberOfItems {
            // 1
            let indexPath = IndexPath(item:item, section:0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 2
            attributes.zIndex = item
            var height = standardHeight
            
            // 3
            if indexPath.item == featuredItemIndex {
                // 4
				let yOffset: CGFloat = standardHeight * nextItemPercentageOffset //- standardHeight * previousItemPercentageOffset
				y = collectionView!.contentOffset.y + (positionOffset * highlightPositionIndex) - yOffset
				// the weird movement is here
                height = max(featuredHeight * max(1.0 - nextItemPercentageOffset, 0.0), standardHeight)
//				print(y)
//				print(height)
			} else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
				// 5
				let maxY = y + standardHeight
				height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
				if nextItemPercentageOffset > 1.0 {
					
				}
//				print(height)
				y = maxY - height + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
			} else if indexPath.item == (featuredItemIndex - 1) {
//				// ??
//
//				let maxY = y + (standardHeight * highlightPositionIndex)
//				height = standardHeight
////				let maxY = y + featuredHeight
////				height = standardHeight + max((featuredHeight - standardHeight) * (previousItemPercentageOffset), 0)
//				y = maxY - height - positionOffset * highlightPositionIndex
////				print(CGRect(x: 0, y: y, width: width, height: height))
////				print(previousItemPercentageOffset)
				
				height = standardHeight
				
				let yOffset: CGFloat = standardHeight * nextItemPercentageOffset //- standardHeight * previousItemPercentageOffset
				y = collectionView!.contentOffset.y + (positionOffset * highlightPositionIndex) - yOffset - (positionOffset)
				
				//				y = maxY - height //+ (positionOffset * CGFloat(featuredItemIndex))
//				print(CGRect(x: 0, y: y, width: width, height: height))
			} else if indexPath.item <= (featuredItemIndex - 1) {
				// ??
				//				let maxY = y + featuredHeight
				//				height = featuredHeight - max((featuredHeight - standardHeight) * (1 - previousItemPercentageOffset), 0)
				//				y = maxY - height
				//				print(CGRect(x: 0, y: y, width: width, height: height))
				//				print(maxY)
				
				
				height = standardHeight
				var fillOffset: CGFloat = 0
				let topFilling = max(highlightPositionIndex - 1.0, 0)
				if CGFloat(featuredItemIndex) <= highlightPositionIndex {
					fillOffset = standardHeight + (CGFloat(featuredItemIndex - indexPath.item) - topFilling) * standardHeight
				} else {
					fillOffset = standardHeight
				}
				
				let yOffset: CGFloat = standardHeight * nextItemPercentageOffset
				
//				y = collectionView!.contentOffset.y - yOffset
				y = collectionView!.contentOffset.y - yOffset + fillOffset // + ( CGFloat(indexPath.item)) * positionOffset // + (max(topPosition, 0))// +  (positionOffset*max((CGFloat(indexPath.item) - highlightPositionIndex), 0))// (positionOffset * highlightPositionIndex) - yOffset// - (positionOffset)// - ((standardHeight*( CGFloat(indexPath.item + 2)))) + (positionOffset*( highlightPositionIndex))
				topPosition -= height
//				y = maxY - height //+ (positionOffset * CGFloat(featuredItemIndex))
					print(CGRect(x: 0, y: y, width: width, height: height))
				print(indexPath.item)
				print(topPosition)
			}
            
            // 6
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
//            y = frame.maxY
			y += height
        }
    }
    
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		
        var itemIndex = round(proposedContentOffset.y / dragOffset)
		itemIndex = proposedContentOffset.y < 0 ? -1 : itemIndex + (highlightPositionIndex <= 2 ? 1 : 2)
        let yOffset = itemIndex * dragOffset
		print(yOffset - positionOffset * highlightPositionIndex)
        return CGPoint(x: 0, y: yOffset - positionOffset * highlightPositionIndex)
    }
}
