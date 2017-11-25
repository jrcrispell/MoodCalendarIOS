//
//  MenuViewController.swift
//  iOSFinalProject
//
//  Created by Jason Crispell on 11/24/17.
//  Copyright © 2017 Crispell Apps. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelected(_ index: Int)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableMenuOptions: UITableView!
    
    // Transparent button to hide menu
    @IBOutlet var closeMenuButton: UIButton!
    
    var menuOptions = [[String:String]]()
    
    var delegate: SlideMenuDelegate?
    
    func updateMenuArrayOptions() {
        menuOptions.append(["title":"Home", "icon":"HomeIcon"])
        menuOptions.append(["title":"Play", "icon":"PlayIcon"])
        tableMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuTapped(_ button: UIButton!) {
        closeMenuButton.tag = 0
        
        if self.delegate != nil {
            var index = Int(button.tag)
            if (button == self.closeMenuButton) {
                index = -1
            }
            delegate?.slideMenuItemSelected(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }) { (finished) in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
