//
//  CMSAudioView.swift
//  CMSAudio
//
//  Created by admin on 2020/9/3.
//  Copyright © 2020 Sihj. All rights reserved.
//

import UIKit
import AVFoundation

public class CMSAudioView: UIView {
    
    /// 播放左边颜色
    public var readColor:UIColor? {
        didSet {
            if let color = readColor {
                self.progressSlider.minimumTrackTintColor = color
                let imageView = puaseBtn.imageView!
                let imageS = self.tintcolorChange(iv: imageView, name: "play", color: color)
                let imageN = self.tintcolorChange(iv: imageView, name: "puase", color: color)
                puaseBtn.setImage(imageN, for: .normal)
                puaseBtn.setImage(imageS, for: .selected)
            }
        }
    }
    /// 播放右边颜色
    public var readyColor:UIColor? {
        didSet {
            if let color = readyColor {
                self.progressSlider.maximumTrackTintColor = color
            }
        }
    }
    /// 时间颜色
    public var timeColor:UIColor? {
        didSet {
            if let color = timeColor {
                self.startTimeLabel.textColor = color
                self.endTimeLabel.textColor = color
            }
        }
    }
    /// 时间字体大小
    public var timeFont:UIFont? {
        didSet {
            if let font = timeFont {
                self.startTimeLabel.font = font
                self.endTimeLabel.font = font
            }
        }
    }
    /// 时间背景颜色
    public var timeBackGroundColor:UIColor? {
        didSet {
            if let color = timeBackGroundColor {
                self.startTimeLabel.backgroundColor = color
                self.endTimeLabel.backgroundColor = color
            }
        }
    }
    /// 切圆角
    public var roundedCornersRadius:CGFloat? {
        didSet {
            if let radius = roundedCornersRadius {
                self.layer.cornerRadius = radius
                self.layer.masksToBounds = true
            }
        }
    }
    
    /// 循环播放
    public var cyclePlay : Bool? = false
    /// 自动播放
    public var autoPlay : Bool? = true
    
    fileprivate var player : AVPlayer?
    fileprivate var playerItem : AVPlayerItem?
    
    /// 播放资源状态
    fileprivate var type : CMSAudioType? = .AudioTypeLocal
    /// 播放资源状态
    fileprivate var status : CMSAudioStatus?
    /// 播放失败
    fileprivate var failed : Bool? = false
    /// 播放定时器
    fileprivate var timer : Timer?
    /// 播放路径
    fileprivate var path : String? = ""
    
    fileprivate var progressSlider = CMSCustomSlider()
    fileprivate var progress = UIProgressView()
    fileprivate var puaseBtn = UIButton(type: .custom)
    fileprivate var startTimeLabel = UILabel()
    fileprivate var endTimeLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**
      *  path: 路径
      *  audioSourceType: 本地文件还是网络文件
      * cacheStatus: 是否缓存
      * autoPlayStatus: 是否自动播放
      * cyclePlayStatus: 是否循环播放
     */
    
    public func initWithPath(frame: CGRect,
                             path: String ,
                             audioSourceType:CMSAudioType? = .AudioTypeLocal,
                             autoPlayStatus: Bool? = true ) {
        self.path = path
        self.type = audioSourceType
        self.frame = frame
        self.status = autoPlayStatus ?? true ? .AudioStatusPlaying : .AudioStatusStopped
        let url = loadSourcePath()
        self.createPlayer(url: url)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        createTopViewAndBottomView()
        contentMasnory()
    }
    
    fileprivate func loadSourcePath() -> URL {
        var url:URL?
        switch self.type {
        case .AudioTypeURL:
            /// 网络文件播放
            url = URL.init(string: self.path!)
        default:
            /// 本地文件播放
            url = URL.init(fileURLWithPath: self.path!)
        }
        return url!
    }
    
    //自定义播放界面
    fileprivate func createTopViewAndBottomView()  {

        progress = UIProgressView.init()
        progress.trackTintColor = UIColor.white
        progress.progressTintColor = UIColor.init(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)
        self.addSubview(progress)
        
        progressSlider = CMSCustomSlider.init()
        progressSlider.isContinuous = false
        progressSlider.sliderHeight = 2
        progressSlider.setThumbImage(UIImage.init(named: "slider"), for: .normal)
        progressSlider.setThumbImage(UIImage.init(named: "slider"), for: .selected)

        // 左边的颜色
//        progressSlider.minimumTrackTintColor = UIColor.white
        // 右边颜色
        progressSlider.maximumTrackTintColor = UIColor.clear
        
        progressSlider.addTarget(self, action: #selector(progressSliderValueChange), for: .valueChanged)
        self.addSubview(progressSlider)

        startTimeLabel.font = UIFont.systemFont(ofSize: 13.0)
        startTimeLabel.textColor = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        startTimeLabel.text = "00:00"
        startTimeLabel.sizeToFit()
        self.addSubview(startTimeLabel)

        endTimeLabel.font = UIFont.systemFont(ofSize: 13.0)
        endTimeLabel.textColor = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        endTimeLabel.text = "00:00"
        endTimeLabel.sizeToFit()
        endTimeLabel.textAlignment = NSTextAlignment.right
        self.addSubview(endTimeLabel)
        
        puaseBtn = UIButton.init(type: .custom)
        puaseBtn.setImage(UIImage.init(named: "play"), for: .selected)
        puaseBtn.setImage(UIImage.init(named: "puase"), for: .normal)
        puaseBtn.addTarget(self, action: #selector(puaseBtnClick(_:)), for: .touchUpInside)
        puaseBtn.isSelected = true
        self.addSubview(puaseBtn)
        
        startTimeLabel.backgroundColor = UIColor.clear
        endTimeLabel.backgroundColor = UIColor.clear
        
    }
    
    fileprivate func createPlayer(url:URL) {
        self.playerItem = AVPlayerItem.init(url: url)
  
        guard let playerItem = playerItem else {
            self.failed = true
            self.loadSourceFail()
            return
        }
        
        self.failed = false
        
        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.player = AVPlayer.init(playerItem: playerItem)
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        playerLayer.videoGravity = AVLayerVideoGravity.resize
        self.layer.addSublayer(playerLayer)
        
        if self.status == CMSAudioStatus.AudioStatusPlaying {
            self.puaseBtnClick(self.puaseBtn)
        }
    }
    
    fileprivate func addTimer() {
        guard let loadPlayItem = failed, loadPlayItem == false else { self.loadSourceFail(); return }
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                self?.timerProgress()
            })
        }
    }
    
    fileprivate func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //        拖动改变视频播放进度
    @objc fileprivate func progressSliderValueChange()  {
        if player?.status == .readyToPlay {
            guard let _ = playerItem else { return }
            let total = Float(playerItem!.duration.value/Int64(playerItem!.duration.timescale))
            let dragedSeconds = floorf(total * progressSlider.value)
            self.resetProgress(value: dragedSeconds)
        }
    }
    
    // 观察者模式 进行进度条的改变
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loadedTimeRanges" {
            let duration = playerItem!.duration
            let total = CMTimeGetSeconds(duration)
            progress.setProgress(Float(total), animated: false)
        }
    }
    //计算时间的方法
    fileprivate func timerProgress()  {
        guard let _ = playerItem else {
            return
        }
        if playerItem!.duration.timescale != 0 {
            progressSlider.maximumValue = 1.0
            let total = Float(playerItem!.duration.value/Int64(playerItem!.duration.timescale))
            progressSlider.value = Float(CMTimeGetSeconds(playerItem!.currentTime()))/total
            //当前分
            let promin = NSInteger(CMTimeGetSeconds(playerItem!.currentTime()))/60
            //当前秒
            let prosec = NSInteger(CMTimeGetSeconds(playerItem!.currentTime()))%60
            
            // 总时间分钟
            let durmin = NSInteger(total)/60
            // 总时间秒
            let dursec = NSInteger(total)%60
            
            self.status = .AudioStatusPlaying
            
            /// 判断是否播放完成
            if promin == durmin {
                if dursec == prosec {
                    self.status = .AudioStatusFinished
                    /// 是否循环播放
                    if self.cyclePlay ?? false {
                        puaseBtn.isSelected = true
                        self.puaseBtnClick(puaseBtn)
                    }
                    else {
                        /// 播放完成，还原设置
                        audioStop()
                    }
                }
            }
            
            startTimeLabel.text = NSString.init(format: "%02ld:%02ld", promin,prosec) as String
            endTimeLabel.text = NSString.init(format: "%02ld:%02ld", durmin,dursec) as String
            resetTimeLabelFrame()
        }
    }
    
    @objc fileprivate func puaseBtnClick(_ btn: UIButton) {
        if btn.isSelected {
            if self.status == .AudioStatusFinished || self.status == .AudioStatusStopped {
                self.progressSlider.value = 0
                self.resetProgress(value: 0)
            }
            else if self.status == .AudioStatusPlaying {
                audioPlay()
            }
            else if self.status == .AudioStatusPaused {
                self.status = .AudioStatusPlaying
                audioPlay()
            }
            
        }else{
            self.status = .AudioStatusPaused
            audioStop()
        }
    }
    
    public func play() {
        puaseBtn.isSelected = true
        self.puaseBtnClick(puaseBtn)
    }
    
    public func puase() {
        puaseBtn.isSelected = false
        self.puaseBtnClick(puaseBtn)
    }
    
    fileprivate func resetProgress(value: Float) {
        let dragedCMTime = CMTime.init(value: CMTimeValue(value), timescale: 1)
        player?.pause()
        removeTimer()
        player!.seek(to: dragedCMTime, completionHandler: { [weak self] (finish) in
            if finish  {
                self?.audioPlay()
            }
        })
    }
    
    fileprivate func loadSourceFail() {
        audioStop()
        self.status = .AudioStatusFailed
        let url = loadSourcePath()
        self.createPlayer(url: url)
    }
    
    fileprivate func audioPlay() {
        player!.play()
        addTimer()
        puaseBtn.isSelected = false
    }
    
    fileprivate func audioStop() {
        player?.pause()
        removeTimer()
        puaseBtn.isSelected = true
    }
    
    fileprivate func tintcolorChange(iv:UIImageView,name: String , color:UIColor) ->UIImage{
        var queImg = UIImage(named: name)
        guard let _ = queImg else {
            return UIImage.init()
        }
        queImg = queImg?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        iv.tintColor = color
        return queImg!
    }
    
    //添加frame
    fileprivate func contentMasnory()  {
        let btnY = (self.frame.size.height - 30)/2.0
        self.puaseBtn.frame = CGRect.init(x: 10, y: btnY, width: 30, height: 30)
        
        let sliderX = self.puaseBtn.frame.size.width + self.puaseBtn.frame.origin.x + 15
        
        self.progressSlider.frame = CGRect.init(x: sliderX, y: 20, width: self.frame.size.width - sliderX - 15, height: 2)
        self.progress.frame = CGRect.init(x: sliderX+2, y: 20, width: self.frame.size.width - sliderX - 15, height: 2)
        resetTimeLabelFrame()
    }
    
    fileprivate func resetTimeLabelFrame() {
        
        startTimeLabel.sizeToFit()
        endTimeLabel.sizeToFit()
        
        let startLabelX = self.progressSlider.frame.origin.x
        let startLabelY = self.progressSlider.frame.origin.y + 10
        self.startTimeLabel.frame = CGRect.init(x: startLabelX, y: startLabelY, width: self.startTimeLabel.frame.width, height: 20)
        self.endTimeLabel.frame = CGRect.init(x: self.frame.size.width - self.endTimeLabel.frame.width - 15, y: startLabelY, width: self.endTimeLabel.frame.width, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
