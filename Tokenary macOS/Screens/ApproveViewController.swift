// Copyright © 2021 Tokenary. All rights reserved.

import Cocoa
import WalletConnect

class ApproveViewController: NSViewController {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet var metaTextView: NSTextView!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var peerNameLabel: NSTextField!
    @IBOutlet weak var peerLogoImageView: NSImageView! {
        didSet {
            peerLogoImageView.wantsLayer = true
            peerLogoImageView.layer?.backgroundColor = NSColor.systemGray.withAlphaComponent(0.5).cgColor
        }
    }
    
    private var approveTitle: String!
    private var meta: String!
    private var completion: ((Bool) -> Void)!
    private var didCallCompletion = false
    private var peerMeta: PeerMeta?
    
    static func with(subject: ApprovalSubject, meta: String, peerMeta: PeerMeta?, completion: @escaping (Bool) -> Void) -> ApproveViewController {
        let new = instantiate(ApproveViewController.self)
        new.completion = completion
        new.meta = meta
        new.approveTitle = subject.title
        new.peerMeta = peerMeta
        return new
    }
    
    func setMeta(_ meta: String) {
        self.meta = meta
        updateDisplayedMeta()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.stringValue = approveTitle
        updateDisplayedMeta()
        if let peer = peerMeta {
            peerNameLabel.stringValue = peer.name
            if let urlString = peer.iconURLString, let url = URL(string: urlString) {
                peerLogoImageView.kf.setImage(with: url) { [weak peerLogoImageView] result in
                    if case .success = result {
                        peerLogoImageView?.layer?.backgroundColor = NSColor.clear.cgColor
                    }
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
    }
    
    private func updateDisplayedMeta() {
        metaTextView.string = meta
    }
    
    private func callCompletion(result: Bool) {
        if !didCallCompletion {
            didCallCompletion = true
            completion(result)
        }
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        callCompletion(result: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: NSButton) {
        callCompletion(result: false)
    }
    
}

extension ApproveViewController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        callCompletion(result: false)
    }
    
}
