//
//  AccountViewController.swift
//  MovingRanking
//
//  Created by Suhyoung Eo on 2022/02/08.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var accountTextLabel: UILabel!
    @IBOutlet weak var accountButton: UIBarButtonItem!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var assessmentListButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func accountButton(_ sender: Any) {
        performSegue(withIdentifier: K.SegueIdentifier.loginView, sender: sender)
    }
    
    @IBAction func wishListButton(_ sender: Any) {
        
    }
    
    @IBAction func assessmentListButton(_ sender: Any) {
        
    }
}
