//
//  ViewController.swift
//  Walking
//
//  Created by Dennis Schmidt on 13/08/2018.
//  Copyright © 2018 Dennis Schmidt. All rights reserved.
//

import UIKit

class MainView: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!

    var parentView: AppDelegate!
    
    //MARK: Initialize
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        print("awakeFromNib")
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("viewDidLoad")
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        print("viewWillTransition")
        
        prepareLayout(to: CGSize(width: size.width, height: size.height))
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        print("viewWillLayoutSubviews")
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        prepareLayout(to: CGSize(width: screenSize.width, height: UIScreen.main.bounds.height))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        
    }
    
    //MARK: Prepare layout
    
    func prepareLayout(to size: CGSize) {
        
        print("prepareLayout")
        
        backgroundImage.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        backgroundImage.clipsToBounds = true
        
        backgroundImage.contentMode = .scaleAspectFill

    }
    
}
