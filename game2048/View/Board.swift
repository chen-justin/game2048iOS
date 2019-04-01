//
//  Board.swift
//  game2048
//
//  Created by Justin Chen on 3/20/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import Foundation

import UIKit

class BoardView: UIView {
    
    var delegate: boardDelegate!
    private var boardSize: Int = 0
    private var gutter: CGFloat = 0
    private var rectSize: CGFloat = 0
    
    let colors = [(#colorLiteral(red: 0.9333333333, green: 0.8941176471, blue: 0.8549019608, alpha: 0.35),#colorLiteral(red: 0.4666666667, green: 0.431372549, blue: 0.3960784314, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 0
        (#colorLiteral(red: 0.9333333333, green: 0.8941176471, blue: 0.8549019608, alpha: 1),#colorLiteral(red: 0.4666666667, green: 0.431372549, blue: 0.3960784314, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 2
        (#colorLiteral(red: 0.9294117647, green: 0.8784313725, blue: 0.7843137255, alpha: 1),#colorLiteral(red: 0.4666666667, green: 0.431372549, blue: 0.3960784314, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 4
        (#colorLiteral(red: 0.9490196078, green: 0.6941176471, blue: 0.4745098039, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 8
        (#colorLiteral(red: 0.9607843137, green: 0.5843137255, blue: 0.3882352941, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 16
        (#colorLiteral(red: 0.9647058824, green: 0.4862745098, blue: 0.3725490196, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 32
        (#colorLiteral(red: 0.9647058824, green: 0.368627451, blue: 0.231372549, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 40)), // 64
        (#colorLiteral(red: 0.9294117647, green: 0.8117647059, blue: 0.4470588235, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 35)), // 128
        (#colorLiteral(red: 0.9294117647, green: 0.8, blue: 0.3803921569, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 35)), // 256
        (#colorLiteral(red: 0.9294117647, green: 0.7843137255, blue: 0.3137254902, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 35)), // 512
        (#colorLiteral(red: 0.9294117647, green: 0.7725490196, blue: 0.2470588235, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 30)), // 1028
        (#colorLiteral(red: 0.9294117647, green: 0.7607843137, blue: 0.1803921569, alpha: 1),#colorLiteral(red: 0.9764705882, green: 0.968627451, blue: 0.9490196078, alpha: 1), UIFont(name: "HelveticaNeue-Bold" , size: 30))] // 2048
    
    
    override func draw(_ frame: CGRect) {
        let w = self.bounds.width
        let color:UIColor = #colorLiteral(red: 0.9333333333, green: 0.8941176471, blue: 0.8549019608, alpha: 0.35) //Default color for square
        boardSize = delegate.getBoardSize()
        color.set()
        
        self.gutter = w/CGFloat((boardSize*8))
        self.rectSize = (w-(gutter*(CGFloat(boardSize+1))))/CGFloat(boardSize)
        
        var x = gutter
        var y = gutter
        
        //Draw underlying squares
        for _ in 0...boardSize - 1 {
            for _ in 0...boardSize - 1 {
                let r = CGRect(x: x, y: y, width: rectSize, height: rectSize)
                let rounded = UIBezierPath(roundedRect: r, cornerRadius: 5)
                rounded.fill()
                x += (gutter + rectSize)
            }
            x = gutter
            y +=  (gutter + rectSize)
        }
        
        //Start drawing tiles
        let tileState = delegate.getTileState()
        for tile in tileState {
            if let tileView = self.viewWithTag(tile.getIdent()) as? UILabel {
                shiftTile(ofView: tileView, toTile: tile)
            } else {
                createTile(tile: tile, withSize: self.rectSize, withGutter: self.gutter)
            }
        }
        
        //Prune tiles that don't exist anymore
        for v in self.subviews {
            let exist = tileState.filter{$0.getIdent() == v.tag}
            if exist.count == 0 {
                if let tileView = v as? UILabel {
                    self.sendSubviewToBack(tileView)
                    UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
                        tileView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }, completion: { finished in
                        tileView.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func resetBoard() {
        for v in self.subviews {
            v.removeFromSuperview()
        }
        self.setNeedsDisplay()
    }
    
    private func shiftTile(ofView tileView: UILabel, toTile tile: Tile) {
        let power = tile.getValue()
        let nextValue = pow(2, power)
        let prevValue = Int(tileView.text!)
        let (tileX, tileY) = tile.getCoordinates()
        let newX = (rectSize + gutter)*CGFloat(tileX) + gutter
        let newY = (rectSize + gutter)*CGFloat(tileY) + gutter
        
        tileView.frame.size = CGSize(width: rectSize, height: rectSize)
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 4/8, animations: {
                if let mergedIdent = tile.popMergedIdent() {
                    if let mergedView = self.viewWithTag(mergedIdent) as? UILabel {
                        mergedView.layer.removeAllAnimations()
                        mergedView.frame.origin.x = newX
                        mergedView.frame.origin.y = newY
                    } else {
                        print("Something went wrong!")
                    }
                }
                tileView.frame.origin.x = newX
                tileView.frame.origin.y = newY
            })
            UIView.addKeyframe(withRelativeStartTime: 4/8, relativeDuration: 2/8, animations: {
                if prevValue! < (nextValue as NSDecimalNumber).intValue {
                    tileView.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
                }
            })
            
            UIView.addKeyframe(withRelativeStartTime: 6/8, relativeDuration: 2/8, animations: {
                tileView.transform = CGAffineTransform.identity
                tileView.text = "\(nextValue)"
                if power < self.colors.count {
                    tileView.backgroundColor = self.colors[power].0
                    tileView.textColor = self.colors[power].1
                    tileView.font = self.colors[power].2
                }
            })
        })
    }
    
    private func createTile(tile: Tile, withSize tileSize: CGFloat, withGutter gutterSize: CGFloat) {
        let (tileX, tileY) = tile.getCoordinates()
        let x = (tileSize + gutterSize)*CGFloat(tileX) + gutterSize
        let y = (tileSize + gutterSize)*CGFloat(tileY) + gutterSize
        let power = tile.getValue()
        let tileView = UILabel(frame: CGRect(x: x, y: y, width: tileSize, height: tileSize))
        
        tileView.text = "\(pow(2, power))"
        if power < self.colors.count {
            tileView.backgroundColor = self.colors[power].0
            tileView.textColor = self.colors[power].1
            tileView.font = self.colors[power].2
        }
        tileView.layer.cornerRadius = 5
        tileView.layer.masksToBounds = true
        tileView.tag = tile.getIdent()
        tileView.textAlignment = .center
        tileView.adjustsFontSizeToFitWidth = true

        //Actually add to board
        self.addSubview(tileView)
        self.sendSubviewToBack(tileView)
        
        //Animate
        tileView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.25,delay: 0.15,
                       animations: {
                        tileView.transform = CGAffineTransform.identity
        })
    }
    
}
