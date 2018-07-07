//
//  DetailViewController.swift
//  Cards
//
//  Created by Paolo Cuscela on 23/10/17.
//

import UIKit

internal class DetailViewController: UIViewController {
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark ))
    var detailView: UIView?
    var scrollView = GesturedScrollView()
    var originalFrame = CGRect.zero
    var snap = UIView()
    var card: Card!
    var delegate: CardDelegate?
    var isFullscreen = false
    
    fileprivate var xButton = XButton()
    
    fileprivate var edgePan: UIScreenEdgePanGestureRecognizer!
    fileprivate var topPan: UIPanGestureRecognizer!
    
    override var prefersStatusBarHidden: Bool {
        if isFullscreen { return true }
        else { return false }
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        self.snap = UIScreen.main.snapshotView(afterScreenUpdates: true)
        self.view.addSubview(blurView)
        self.view.addSubview(scrollView)
        
        if let detail = detailView {
            
            scrollView.addSubview(detail)
            detail.alpha = 0
            detail.autoresizingMask = .flexibleWidth
        }
        
        blurView.frame = self.view.bounds
        
        scrollView.layer.backgroundColor = detailView?.backgroundColor?.cgColor ?? UIColor.white.cgColor
        scrollView.layer.cornerRadius = isFullscreen ? 0 :  20
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
		scrollView.indicatorStyle = .white
        scrollView.showsHorizontalScrollIndicator = false
        
        xButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        scrollView.addGestureRecognizer(edgePan)
        
        topPan = UIPanGestureRecognizer(target: self, action: #selector(screenTopPan))
        topPan.delegate = self
        //        topPan.isEnabled = false
        scrollView.addGestureRecognizer(topPan)
        
        
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        xButton.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.addSubview(card.backgroundIV)
        self.delegate?.cardWillShowDetailView?(card: self.card)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        originalFrame = scrollView.frame
        
        if isFullscreen {
            view.addSubview(xButton)
        }
        
        view.insertSubview(snap, belowSubview: blurView)
        
        if let detail = detailView {
            
            detail.alpha = 1
            detail.frame = CGRect(x: 0,
                                  y: card.backgroundIV.bounds.maxY,
                                  width: scrollView.frame.width,
                                  height: detail.frame.height)
            
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: detail.frame.maxY)
            
            
            xButton.frame = CGRect (x: scrollView.frame.maxX - 20 - 40,
                                    y: scrollView.frame.minY + 20,
                                    width: 40,
                                    height: 40)
            
            
            
        }
        
        self.scrollView.panGestureRecognizer.isEnabled = true
        
        self.delegate?.cardDidShowDetailView?(card: self.card)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.cardWillCloseDetailView?(card: self.card)
        detailView?.alpha = 0
        snap.removeFromSuperview()
        xButton.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.cardDidCloseDetailView?(card: self.card)
    }
    
    
    //MARK: - Layout & Animations for the content ( rect = Scrollview + card + detail )
    
    func layout(_ rect: CGRect, isPresenting: Bool, isAnimating: Bool = true, transform: CGAffineTransform = CGAffineTransform.identity){
        
        guard isPresenting else {
            
            scrollView.frame = rect.applying(transform)
            card.backgroundIV.frame = scrollView.bounds
            card.layout(animating: isAnimating)
            return
        }
        
        if isFullscreen {
            
            scrollView.frame = view.bounds
            scrollView.frame.origin.y = 0
            
        } else {
            scrollView.frame.size = CGSize(width: LayoutHelper.XScreen(85), height: LayoutHelper.YScreen(100) - 20)
            scrollView.center = blurView.center
            scrollView.frame.origin.y = 40
        }
        
        scrollView.frame = scrollView.frame.applying(transform)
        
        card.backgroundIV.frame.origin = scrollView.bounds.origin
		var aspectRatio: CGFloat =  (card.backgroundImage != nil) ? card.backgroundImage!.size.width / card.backgroundImage!.size.height : 1
		let width = scrollView.bounds.width
		let height = aspectRatio > 1.0 ? card.backgroundIV.bounds.height : width / aspectRatio
        card.backgroundIV.frame.size = CGSize( width: width,
                                               height: height)
        card.layout(animating: isAnimating)
        
    }
    
    
    //MARK: - Actions
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let outline = recognizer.translation(in: view)
        scrollViewSizeDrag(outline: outline.x)
        if recognizer.state == .recognized {
            resetScrollViewSize()
        }
    }
    
    @objc func screenTopPan(_ recognizer: UIPanGestureRecognizer) {
        if scrollView.contentOffset.y > 0 { return }
        let outline = recognizer.translation(in: view)
        //        if outline.y < 0 { scrollView.panGestureRecognizer.isEnabled = true; scrollView.contentOffset.y = -outline.y; scrollView.scrollRectToVisible(CGRect(x: 0, y: -outline.y, width: 0, height: 0), animated: false) }
        scrollViewSizeDrag(outline: outline.y)
        if recognizer.state == .ended {
            resetScrollViewSize()
        }
    }
    
    func scrollViewSizeDrag(outline: CGFloat) {
        let dragThreadhold = view.frame.size.width * 2/5
        let ratio = outline > 0 ? 0.7 + 0.3 * (dragThreadhold - outline) / dragThreadhold : 1
        
        if self.isFullscreen {
            
            scrollView.frame.size = CGSize(width: self.view.bounds.width * ratio, height: self.view.bounds.height * ratio)
            scrollView.layer.cornerRadius = card.cardRadius * (1 - ratio)
            scrollView.center = self.blurView.center
            
            
        } else {
            scrollView.frame.size = CGSize(width: LayoutHelper.XScreen(85) * ratio, height: LayoutHelper.YScreen(100) * ratio - 20)
            scrollView.center = self.blurView.center
            
        }
        
        let y = scrollView.contentOffset.y
        xButton.alpha = (y - (card.backgroundIV.bounds.height * 0.6)) * ratio
        
        if outline > dragThreadhold {
            dismissVC()
        }
    }
    
    func resetScrollViewSize() {
        UIView.animate(withDuration: 0.3) {
            if self.isFullscreen {
                self.scrollView.frame.size = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
                self.scrollView.sizeToFit()
                self.scrollView.layer.cornerRadius = 0
                self.scrollView.center = self.blurView.center
            } else {
                self.scrollView.frame.size = CGSize(width: LayoutHelper.XScreen(85), height: LayoutHelper.YScreen(100) - 20)
                self.scrollView.center = self.blurView.center
            }
        }
        self.scrollView.panGestureRecognizer.isEnabled = true
    }
    
    @objc func dismissVC(){
        scrollView.contentOffset.y = 0
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - ScrollView Behaviour

extension DetailViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        //        let origin = originalFrame.origin.y
        //        let currentOrigin = originalFrame.origin.y
        
        xButton.alpha = y - (card.backgroundIV.bounds.height * 0.6)
        
        //        if (y<0  || currentOrigin > origin) {
        //            scrollView.frame.origin.y -= y/2
        //
        //            scrollView.contentOffset.y = 0
        //        }
        if y < 0 {
            self.scrollView.panGestureRecognizer.isEnabled = false
            let gesture = UIPanGestureRecognizer()
            gesture.setTranslation(CGPoint(x: 0, y: 1), in: scrollView)
            screenTopPan(gesture)
        }
        //        else if y > 0 {
        //            resetScrollViewSize()
        //        }
        card.delegate?.cardDetailIsScrolling?(card: card)
    }
    
    //    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //
    //        let origin = originalFrame.origin.y
    //        let currentOrigin = scrollView.frame.origin.y
    //        let max = 4.0
    //        let min = 2.0
    //        var speed = Double(-velocity.y)
    //
    //        if speed > max { speed = max }
    //        if speed < min { speed = min }
    //
    //        //self.bounceIntensity = CGFloat(speed-1)
    //        speed = (max/speed*min)/10
    //
    ////        guard (currentOrigin - origin) < 60 else { dismiss(animated: true, completion: nil); return }
    ////        UIView.animate(withDuration: speed) { scrollView.frame.origin.y = self.originalFrame.origin.y }
    //    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        UIView.animate(withDuration: 0.1) { scrollView.frame.origin.y = self.originalFrame.origin.y }
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.topPan && otherGestureRecognizer == self.edgePan { return true }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
class XButton: UIButton {
    
    private let circle = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override var frame: CGRect {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let xPath = UIBezierPath()
        let xLayer = CAShapeLayer()
        let inset = rect.width * 0.3
        
        xPath.move(to: CGPoint(x: inset, y: inset))
        xPath.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        
        xPath.move(to: CGPoint(x: rect.maxX - inset, y: inset))
        xPath.addLine(to: CGPoint(x: inset, y: rect.maxY - inset))
        
        xLayer.path = xPath.cgPath
        
        xLayer.strokeColor = UIColor.white.cgColor
        xLayer.lineWidth = 2.0
        self.layer.addSublayer(xLayer)
        
        circle.frame = rect
        circle.layer.cornerRadius = circle.bounds.width / 2
        circle.clipsToBounds = true
        circle.isUserInteractionEnabled = false
        
        
    }
    
    
}

class GesturedScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(otherGestureRecognizer)
        //        if otherGestureRecognizer.state == .began { return true }
        return true
    }
    
}








