//
//  HolderTextView.swift
//  HolderTextViewTest
//
//  Created by 陈鲲鹏 on 15/3/1.
//  Copyright (c) 2015年 陈鲲鹏. All rights reserved.
//

import UIKit

@objc protocol HolderTextViewDelegate {
    @objc optional func holderTextViewDidChange(_ textView:HolderTextView)
    @objc optional func returnButtonDidClick(_ textView:HolderTextView)
}

class HolderTextView: UITextView {
    
    var placeHolderView : UITextView!
    fileprivate var initFlag : Bool = false
    var maxLength : Int = 140
    weak var holderTextViewDelegate: HolderTextViewDelegate?
    
    var placeHolder : String = "" {
        didSet{
            placeHolderView.text = placeHolder
        }
    }
    
    override var font: UIFont! {
        didSet{
            if let _ = placeHolderView {
                placeHolderView.font = font
            }
        }
    }
    
    //针对语音输入或者直接赋值
    override var text: String! {
        didSet{
            self.textViewDidChange(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initPlacHolderView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if !initFlag {
            placeHolderView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            placeHolderView.textAlignment = self.textAlignment
            self.contentOffset = CGPoint.zero
            initFlag = true
//        }
    }
}

//MARK: -类方法
extension HolderTextView {
    func initPlacHolderView() {
        placeHolderView = UITextView()
        placeHolderView.text = placeHolder
        placeHolderView.textColor = UIColor.lightGray
        placeHolderView.backgroundColor = UIColor.clear
        placeHolderView.isUserInteractionEnabled = false
        placeHolderView.font = self.font
        self.delegate = self
        placeHolderView.textAlignment = self.textAlignment
        self.addSubview(placeHolderView)
        
    }
    
    fileprivate func limitTextLength(_ textView: UITextView){
        let toBeString = textView.text as NSString
        if (toBeString.length > maxLength) {
            textView.text = toBeString.substring(to: maxLength)
        }
    }
    
    func forceFullyUpdatePlaceHolder(){
        if self.text.isEmpty {
            placeHolderView.isHidden = false
        }else{
            placeHolderView.isHidden = true
        }
        placeHolderView.textAlignment = self.textAlignment
        placeHolderView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
}

//MARK: -UITextViewDelegate
extension HolderTextView:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView){
        if textView.text.isEmpty {
            placeHolderView.isHidden = false
        }else{
            placeHolderView.isHidden = true
        }
        let language = textView.textInputMode?.primaryLanguage
        if let lang = language {
            if lang == "zh-Hans" ||  lang == "zh-Hant" || lang == "ja-JP"{ //如果是中文简体,或者繁体输入,或者是日文这种带默认带高亮的输入法
                let selectedRange = textView.markedTextRange
                var position : UITextPosition?
                if let range = selectedRange {
                    position = textView.position(from: range.start, offset: 0)
                }
                //系统默认中文输入法会导致英文高亮部分进入输入统计，对输入完成的时候进行字数统计
                if position == nil {
                    //                    FLOG("没有高亮，输入完毕")
                    limitTextLength(textView)
                    if let delegate = self.holderTextViewDelegate , delegate.holderTextViewDidChange != nil {
                        delegate.holderTextViewDidChange!(textView as! HolderTextView)
                    }
                }
            }else{//非中文输入法
                limitTextLength(textView)
                if let delegate = self.holderTextViewDelegate , delegate.holderTextViewDidChange != nil {
                    delegate.holderTextViewDidChange!(textView as! HolderTextView)
                }
            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if let delegate = self.holderTextViewDelegate , delegate.returnButtonDidClick != nil {
            if text == "\n" {
                delegate.returnButtonDidClick!(textView as! HolderTextView)
                return !(textView.returnKeyType == .done)
            }
        }
        return true
    }
}
