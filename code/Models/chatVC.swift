//
//  chatVC.swift
//  都信
//
//  Created by 李杰 on 2020/2/27.
//  Copyright © 2020 李杰. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UIBarButtonItem!
    
    @IBOutlet weak var messageTV: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var sendMessageBtnW: NSLayoutConstraint!
    @IBOutlet weak var emojiBtn: UIButton!
    
    var currentFriendsList:[FriendInfo] = []
    var messageID:String!{
        didSet
        {
            print("set messageID to : \(messageID)")
            if let dic = messagesDics[messageID]?.last,
               let friendList = dic["friendList"] as? [FriendInfo]{
                currentFriendsList = friendList
            }
        }
    }
    var messageName:String!
    var addview:AddView?
    var moveH:CGFloat?
    var cfram:CGRect?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentFriendsList.count < 3
        {
            for fInfo in currentFriendsList {
                if fInfo.telephone != mainUserInfo.telephone {
                    nameLabel.title = fInfo.name
                    messageName = fInfo.name
                }
            }
        } else {
            print("more than 2 friends's message")
            nameLabel.title = "多人聊天，还未设置"
            messageName = "多人聊天，还未设置"
        }
        
        if currentFriendsList.count == 1 {
            let meInfo = FriendInfo()
            meInfo.telephone = mainUserInfo.telephone
            meInfo.name = mainUserInfo.name
            meInfo.sex = mainUserInfo.sex
            meInfo.publicIP = mainUserInfo.publicIP
            currentFriendsList.append(meInfo)
        }
        
        if messageID == nil {
            currentFriendsList.sort(by: { (f2:FriendInfo,f1:FriendInfo) ->Bool in  //f2是后面的那个元素currentFriendsList[1]，f2是前面的那个元素currentFriendsList[0]。是反序
                return f2.telephone! < f1.telephone!;
            })
            messageID = "\(currentFriendsList[0].telephone!)-\(currentFriendsList[1].telephone!)".md5
        }
        
        print("the friend IP is : \(currentFriendsList[0].publicIP!)")
        
        
        let viewSingleTapGesture = UITapGestureRecognizer(target: self, action: #selector(backViewClick))
        self.view.addGestureRecognizer(viewSingleTapGesture)
        self.view.isUserInteractionEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none;//去掉Cell之间的间隔线
    
        self.view.sendSubviewToBack(contentView)
        let statusBarFram = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame;
        let statusBarView = UIView(frame: statusBarFram!)
        statusBarView.backgroundColor = UIColor.hexColor(hex: "EBEBEB")
        self.view.addSubview(statusBarView)
        
        addview = (Bundle.main.loadNibNamed("AddView", owner: self, options: nil)?.last as! AddView)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("init viewDidAppear cfram \(self.contentView.frame)")
                print("moveH \(moveH)")
        cfram = self.contentView.frame
        moveH = cfram!.size.height*0.4
        addview!.frame = CGRect(x: cfram!.origin.x, y: cfram!.origin.y+cfram!.size.height, width: cfram!.size.width, height: moveH!)
        self.view.addSubview(addview!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let count = messagesDics[self.messageID]?.count,count>0 {
            self.tableView.scrollToRow(at: IndexPath(row: count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let count = messagesDics[self.messageID]?.count,
            count>0{
            self.tableView.scrollToRow(at: IndexPath(row: messagesDics[self.messageID]!.count-1, section: 0), at: .bottom, animated: false)
        }
        
        sendMessageBtn.setImage(UIImage(named: "plus")?.reSizeImage(reSize: CGSize(width: 28,height: 28))?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        emojiBtn.setImage(UIImage(named: "smile")?.reSizeImage(reSize: CGSize(width: 40,height: 40))?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        print("go back clicked")
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func backViewClick(){
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: { ()-> Void in
            self.contentView.frame.origin.y = self.cfram!.origin.y
            self.addview!.frame = CGRect(x: self.cfram!.origin.x, y: self.cfram!.origin.y+self.cfram!.size.height, width: self.cfram!.size.width, height: self.moveH!)
        })
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseIn,animations: { () -> Void in
            print("in animate cfram \(self.cfram)")
            self.contentView.frame.origin.y = self.cfram!.origin.y - (keyboardFrame?.size.height)!
        }, completion: { (flg) -> Void in
            //self.tableView.scrollToRow(at: IndexPath(row: messagesDics[self.messageID]!.count-1, section: 0), at: .bottom, animated: true)
        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseIn,animations: { () -> Void in
            self.contentView.frame.origin.y = self.cfram!.origin.y //(keyboardFrame?.size.height)!
            self.addview!.frame = CGRect(x: self.cfram!.origin.x, y: self.cfram!.origin.y+self.cfram!.size.height, width: self.cfram!.size.width, height: self.moveH!)
        }, completion: { (flg) -> Void in
            //self.tableView.scrollToRow(at: IndexPath(row: messagesDics[self.messageID]!.count-1, section: 0), at: .bottom, animated: true)
        })
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        print(sender.tag)
        
        if sender.tag == 1 {
            setSendBtnTitletoPlus(senderBtn: sender)
        } else { //处于加号状态时点击
            
            UIView.animate(withDuration: 0.4, animations: { ()->Void in
                self.addview!.frame.origin.y -= self.moveH!
                self.contentView.frame.origin.y -= self.moveH!
            })
            
            
            //setSendBtnTitleToSend(senderBtn: sender)
            return
        }
        
        if messageTV.text == "" {
            print("have no message")
            return
        }
        
        if let messageData = messageTV.text.data(using: .utf8) {
            
            for finfo in currentFriendsList {
                if finfo.telephone==mainUserInfo.telephone {
                    continue
                }
                
                var optionDic : [String: AnyObject] = [:]
                optionDic["telephone"] = mainUserInfo.telephone as AnyObject?
                optionDic["targetTelephone"] = finfo.telephone as AnyObject?
                optionDic["action"] = 1 as AnyObject?
                let convertStr:String =  JSONTools.shared.convertDictionaryToString(dict: optionDic)
                
                var messageDic : [String: AnyObject] = [:]
                messageDic["messageType"] = "friendsMessage" as AnyObject?
                messageDic["messageFrom"] = mainUserInfo.telephone as AnyObject?
                messageDic["messageID"] = messageID as AnyObject?
                messageDic["messageName"] = messageName as AnyObject?
                messageDic["messageDataType"] = "String" as AnyObject?
                messageDic["messageData"] = messageData as AnyObject?
                messageDic["friendList"] = currentFriendsList as AnyObject?
                
                let messageDicData = NSKeyedArchiver.archivedData(withRootObject:messageDic as NSDictionary)
                //print("messageDicData: \(messageDicData)")
                
                //let dic = NSKeyedUnarchiver.unarchiveObject(with: messageDicData) as! NSDictionary
                //print("unarchiveObject messageDic: \(dic)")
                
                let sendData = "\(convertStr)####DATA####".data(using: .utf8)! + messageDicData
                
                UdpManager.shared.sendData(data: sendData, toHost: httpManager.shared.serverIP, port: httpManager.shared.serverPort)
                
                appendMessage(dic: messageDic as NSDictionary)
                
                messageTV.text = ""
                self.view.endEditing(true)
            }
            
        }
        
    }
    
    func setSendBtnTitletoPlus(senderBtn: UIButton) -> Void {
        senderBtn.tag = 0
        UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveLinear,animations: { () -> Void in
            self.sendMessageBtnW.constant = 32
            self.messageTV.frame = CGRect(x: self.messageTV.frame.origin.x, y: self.messageTV.frame.origin.y, width: self.messageTV.frame.size.width+28, height: self.messageTV.frame.height)
            self.emojiBtn.frame = CGRect(x: self.emojiBtn.frame.origin.x+28, y: self.sendMessageBtn.frame.origin.y, width: self.emojiBtn.frame.width, height: self.emojiBtn.frame.height)
            self.sendMessageBtn.frame = CGRect(x: self.sendMessageBtn.frame.origin.x+28, y: self.sendMessageBtn.frame.origin.y, width: 32, height: 32)
            
            senderBtn.setTitle("", for: .normal)
            senderBtn.backgroundColor = UIColor.clear
            senderBtn.setImage(UIImage(named: "plus")?.reSizeImage(reSize: CGSize(width: 28,height: 28))?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        }, completion: { (flg) -> Void in
            
        })
    }
    
    
    func setSendBtnTitleToSend(senderBtn: UIButton) -> Void {
        senderBtn.tag = 1
        senderBtn.setTitle("发送", for: .normal)
        senderBtn.backgroundColor = UIColor.systemGreen
        senderBtn.setImage(nil, for: .normal)
        UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions.curveLinear,animations: { () -> Void in
            self.sendMessageBtnW.constant = 60
            self.messageTV.frame = CGRect(x: self.messageTV.frame.origin.x, y: self.messageTV.frame.origin.y, width: self.messageTV.frame.size.width-28, height: self.messageTV.frame.height)
            self.emojiBtn.frame = CGRect(x: self.emojiBtn.frame.origin.x-28, y: self.sendMessageBtn.frame.origin.y, width: self.emojiBtn.frame.width, height: self.emojiBtn.frame.height)
            self.sendMessageBtn.frame = CGRect(x: self.sendMessageBtn.frame.origin.x-28, y: self.sendMessageBtn.frame.origin.y, width: 60, height: self.sendMessageBtn.frame.size.height)
        }, completion: nil)
    }
    
    
    func appendMessage(dic:NSDictionary) -> Void {
        if (messagesDics.keys.contains(messageID)) {
            messagesDics[messageID]?.append(dic as NSDictionary)
        } else {
            messagesDics[messageID] = [dic as NSDictionary]
        }
        
        tableView.reloadData()
        
        DispatchQueue.main.async{
            self.tableView.scrollToRow(at: IndexPath(row: messagesDics[self.messageID]!.count-1, section: 0), at: .bottom, animated: true)
        }
        
//        print("\n\n\n\n\n ============== messagesDics:")
//        for i in (0..<messagesDics[messageID]!.count) {
//             if let dic = messagesDics[messageID]?[i],
//                let messagedata = dic["messageData"] as? Data{
//                    let messagestr = String(data: messagedata, encoding: .utf8) ?? ""
//                    print("message\(i): \(messagestr)")
//            }
//        }
        
        MyFileManager.saveMessagesDic()
    }
}


extension ChatViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("return cell height")
        //print("indexPath.row:  \(indexPath.row)  indexPath.section: \(indexPath.section)")
        var messagestr = ""
        if let dic = messagesDics[messageID]?[indexPath.row],
           let messagedata = dic["messageData"] as? Data{
            messagestr = String(data: messagedata, encoding: .utf8) ?? ""
            
            let size = messagedata.count
            
            var height = 10+(1+size/25)*25
            
            let returnCount = RegularTools.shared.RegularExpression(regex: "\n", validateString: messagestr).count
            
            height += returnCount*25
            
            height = height<50 ? 50:height
            
            return CGFloat(height)
        }
        
        return 50
    }
    
    //设置列表有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDics[messageID]?.count ?? 0
    }
    //设置每行数据的数据载体Cell视图
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("return cell view")
        //print("indexPath.row:  \(indexPath.row)  indexPath.section: \(indexPath.section)")
        
        let dic = messagesDics[messageID]?[indexPath.row]
        if dic?["messageFrom"] as? String == mainUserInfo.telephone {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MineChatVCellID", for: indexPath) as! MineChatVCCell
            
            if let messagedata = dic?["messageData"] as? Data,
                let messagestr = String(data: messagedata, encoding: .utf8){
                cell.messageBV.setMessageStr(message: messagestr)
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCellID", for: indexPath) as! ChatVCCell
        
        if let messagedata = dic?["messageData"] as? Data,
            let messagestr = String(data: messagedata, encoding: .utf8){
            cell.messageBV.setMessageStr(message: messagestr)
        }
        
        return cell
    }
    
    //设置列表的分区数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //设置索引栏标题
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    //设置分区头部标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    //这个方法将索引栏上的文字与具体的分区进行绑定
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("in didSelectRowAt indexPath indexPath.row:  \(indexPath.row)  indexPath.section: \(indexPath.section)")
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("in  willDisplay cell indexPath.row:  \(indexPath.row)  indexPath.section: \(indexPath.section)")
//    }
    
    
}
