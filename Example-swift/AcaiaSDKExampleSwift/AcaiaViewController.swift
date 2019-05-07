//
//  AcaiaViewController.swift
//  AcaiaSDKExampleSwift
//
//  Created by Michael Wu on 2018/7/4.
//  Copyright © 2018 acaia Corp. All rights reserved.
//

import UIKit
import AVKit
import AcaiaSDK

class AcaiaViewController: UIViewController {
    @IBOutlet var scaleNameL: UILabel!
    @IBOutlet var weightL: UILabel!
    @IBOutlet var timerL: UILabel!
    @IBOutlet var toolView: UIView!
    @IBOutlet var btnTimer: UIButton!
    @IBOutlet var btnPauseTimer: UIButton!
    @IBOutlet var btnDisconnect: UIButton!
    @IBOutlet var btnTare: UIButton!
    @IBOutlet var btnStart: UIButton!
    let remoteFileUrl: String = "https://r2---sn-oguelnle.googlevideo.com/videoplayback?id=o-AE0sLs2GBSeshCjXeVLOSeZGJdldifiFli_iS_K8sO6h&itag=18&source=youtube&requiressl=yes&pl=17&ei=su7QXPbJEdfVgAPGjLeACg&mime=video%2Fmp4&gir=yes&clen=32596876&ratebypass=yes&dur=365.203&lmt=1355362931357395&fvip=2&c=WEB&ip=2001%3Ae42%3A102%3A1206%3A153%3A121%3A64%3A226&ipbits=0&expire=1557218066&sparams=clen,dur,ei,expire,gir,id,ip,ipbits,ipbypass,itag,lmt,mime,mip,mm,mn,ms,mv,pl,ratebypass,requiressl,source&signature=6E3EE03B6C8713965724AD9ECA6BBB665BBAAD53.2A8F7A167E965F908813374ABC17452F9A3BDF99&key=cms1&title=%E3%82%B3%E3%83%AD%E3%83%B3%E3%83%93%E3%82%A2%E3%82%B3%E3%83%BC%E3%83%92%E3%83%BC%E7%94%A3%E5%9C%B0%E3%81%AE%E5%86%8D%E7%94%9F&rm=sn-oguk67d&req_id=336a148641bba3ee&ipbypass=yes&mip=133.26.40.26&redirect_counter=2&cm2rm=sn-xgmnpoxuopp-ioqe7l&cms_redirect=yes&mm=29&mn=sn-oguelnle&ms=rdu&mt=1557202321&mv=m"
    var isTimerStarted:Bool = false;
    var isTimerPaused:Bool = false;
    var isTotatsu:Bool = false;
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onConnect(noti:)), name: NSNotification.Name(rawValue: AcaiaScaleDidConnected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFailed(noti:)), name: NSNotification.Name(rawValue: AcaiaScaleConnectFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDisconnect(noti:)), name: NSNotification.Name(rawValue: AcaiaScaleDidDisconnected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWeight(noti:)), name: NSNotification.Name(rawValue: AcaiaScaleWeight), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTimer(noti:)), name: NSNotification.Name(rawValue: AcaiaScaleTimer), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    @objc func onConnect(noti: NSNotification) {
        self.refreshUI()
    }
    @objc func onFailed(noti: NSNotification) {
        self.refreshUI()
    }
    
    @objc func onDisconnect(noti: NSNotification) {
        self.refreshUI()
    }
    
    @objc func onWeight(noti: NSNotification) {
        let unit = noti.userInfo![AcaiaScaleUserInfoKeyUnit]! as! NSNumber
        let weight = noti.userInfo![AcaiaScaleUserInfoKeyWeight]! as! Float
        
        if(weight >= 30.0){
            self.isTotatsu = true;
        }
        if unit.intValue == AcaiaScaleWeightUnit.gram.rawValue {
            self.weightL.text = String(format: "%.1f g", weight)
        } else {
            self.weightL.text = String(format: "%.4f oz", weight)
        }
    }
    
    @objc func onTimer(noti: NSNotification) {
        let time = noti.userInfo![AcaiaScaleUserInfoKeyTimer] as! Int
        self.timerL.text = String(format: "%02d:%02d", time/60, time%60)
        self.isTimerStarted = true;
    }
    
    func refreshUI() {
        if let scale = AcaiaManager.shared().connectedScale {
            self.scaleNameL.text = scale.name;
            self.toolView.isHidden = false;
        } else {
            self.toolView.isHidden = true;
            self.scaleNameL.text = "-";
            self.timerL.text = "-";
            self.weightL.text = "-";
        }
    }
    @IBAction func onBtnTimer() {
        if let scale = AcaiaManager.shared().connectedScale {
            if self.isTimerStarted {
                self.isTimerStarted = false;
                self.isTimerPaused = false;
                scale.stopTimer()
                self.btnPauseTimer.isEnabled = false;
                self.btnTimer.setTitle("Start Timer", for: UIControl.State.normal)
                self.btnPauseTimer.setTitle("Pause Timer", for: UIControl.State.normal)
                self.timerL.text = "-";

            } else {
                self.btnPauseTimer.isEnabled = true;
                scale.startTimer()
                self.btnTimer.setTitle("Stop Timer", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func onBtnPauseTimer() {
        if let scale = AcaiaManager.shared().connectedScale {
            if self.isTimerPaused {
                self.isTimerPaused = false
                scale.startTimer()
                self.btnPauseTimer.setTitle("Pause Timer", for: UIControl.State.normal)
            } else {
                self.isTimerPaused = true
                scale.pauseTimer()
                self.btnPauseTimer.setTitle("Resume Timer", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func onBtnTare() {
        if let scale = AcaiaManager.shared().connectedScale {
            scale.tare()
        }
    }
    
    @IBAction func onBtnDisconnect() {
        if let scale = AcaiaManager.shared().connectedScale {
            scale.disconnect()
        }
    }
    
    @IBAction func onBtnStart(_ sender: Any) {
        if let scale = AcaiaManager.shared().connectedScale {
            if self.isTimerStarted {
                self.isTimerStarted = false;
                self.isTimerPaused = false;
                scale.stopTimer()
                self.btnPauseTimer.isEnabled = false;
                self.btnTimer.setTitle("Start Timer", for: UIControl.State.normal)
                self.btnPauseTimer.setTitle("Pause Timer", for: UIControl.State.normal)
                self.timerL.text = "-";
                if(isTotatsu){
                    playMovieFromUrl(movieUrl: URL(string: remoteFileUrl))
                }
                
            } else {
                self.btnPauseTimer.isEnabled = true;
                scale.startTimer()
                self.btnTimer.setTitle("Stop Timer", for: UIControl.State.normal)
            }
        }
        
    }
    
    func playMovieFromUrl(movieUrl: URL?) {
        if let movieUrl = movieUrl {
            // https://developer.apple.com/documentation/avfoundation/avasset
            let videoPlayer = AVPlayer(url: movieUrl)
            let playerController = AVPlayerViewController()
            playerController.player = videoPlayer
            self.present(playerController, animated: true, completion: {
                videoPlayer.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 39.0) {
                    // 30秒ご
                    videoPlayer.pause()
                }
                
            })
        } else {
            print("cannot play")
        }
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
