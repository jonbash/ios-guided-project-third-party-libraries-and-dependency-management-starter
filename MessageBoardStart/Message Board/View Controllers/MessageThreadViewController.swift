//
//  MessageThreadViewController.swift
//  Message Board
//
//  Created by Jon Bash on 2019-12-17.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageThreadViewController: MessagesViewController {
    var messageThreadController: MessageThreadController?
    
    var messageThread: MessageThread?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension MessageThreadViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return messageThreadController?.currentUser ?? Sender(senderId: UUID().uuidString,
                                                             displayName: "Unknown User")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let thread = messageThread else {
            fatalError("No message found in thread")
        }
        
        return thread.messages[indexPath.item]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageThread?.messages.count ?? 0
    }
}

extension MessageThreadViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension MessageThreadViewController: MessagesDisplayDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard
            let messageThread = messageThread,
            let currentSender = currentSender() as? Sender
            else { return }
        
        messageThreadController?.createMessage(
            in: messageThread,
            withText: text,
            sender: currentSender)
        {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
        }
        
        inputBar.inputTextView.text = ""
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .green
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let initials = String(message.sender.displayName.first ?? Character(""))
        let avatar = Avatar(image: nil, initials: initials)
        avatarView.set(avatar: avatar)
    }
}

extension MessageThreadViewController: MessageInputBarDelegate {}
