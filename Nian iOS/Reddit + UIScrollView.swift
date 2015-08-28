//
//  Reddit + UIScrollView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
extension RedditViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var x = scrollView.contentOffset.x
            labelLeft.setTabAlpha(x, index: 0)
            labelRight.setTabAlpha(x, index: 1)
        }
    }
    
    func onLeft() {
        switchTab(0)
    }
    
    func onRight() {
        switchTab(1)
    }
    
    func switchTab(index: Int) {
        scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(index), 0), animated: true)
        if index == current {
            if index == 0 {
                tableViewLeft.headerBeginRefreshing()
            } else {
                tableViewRight.headerBeginRefreshing()
            }
        } else {
            if index == 0 {
                if dataArrayLeft.count == 0 {
                    tableViewLeft.headerBeginRefreshing()
                }
            } else {
                if dataArrayRight.count == 0 {
                    tableViewRight.headerBeginRefreshing()
                }
            }
            current = index
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var x = scrollView.contentOffset.x
            current = Int(x / globalWidth)
            if current == 0 {
                if dataArrayLeft.count == 0 {
                    tableViewLeft.headerBeginRefreshing()
                }
            } else {
                if dataArrayRight.count == 0 {
                    tableViewRight.headerBeginRefreshing()
                }
            }
        }
    }
}