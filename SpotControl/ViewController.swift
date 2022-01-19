//
//  ViewController.swift
//  SpotControl
//
//  Created by Victor Belov on 26.12.2021.
//

import UIKit
import CDJoystick
import OSLog
import Network

class ViewController: UIViewController {
    
    @IBOutlet weak var leftJoystick: CDJoystick!
    @IBOutlet weak var rightJoystick: CDJoystick!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var walkButton: UIButton!
    
    var connection: NWConnection?
//    var hostUDP: NWEndpoint.Host = "jetson1.home"
    var hostUDP: NWEndpoint.Host = "192.168.1.109"
    var portUDP: NWEndpoint.Port = 12345
    var leftVelocityX, leftVelocityY, rightVelocityX, rightVelocityY: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        let orientationValue = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        leftVelocityX = 0
        leftVelocityY = 0
        rightVelocityX = 0
        rightVelocityY = 0
        leftJoystick.trackingHandler = { joystickData in
            if (joystickData.velocity.x != self.leftVelocityX || joystickData.velocity.y != self.leftVelocityY) {
                os_log("Left joystick data")
                os_log("VelocityX = %f", joystickData.velocity.x)
                os_log("VelocityY = %f", joystickData.velocity.y)
                let data = String(format: "LEFT %.2f %.2f\n", joystickData.velocity.x, joystickData.velocity.y)
                self.sendUDP(data.data(using: .utf8)!)
                self.leftVelocityX = joystickData.velocity.x
                self.leftVelocityY = joystickData.velocity.y
            }
        }
        rightJoystick.trackingHandler = { joystickData in
            if (joystickData.velocity.x != self.rightVelocityX || joystickData.velocity.y != self.rightVelocityY) {
                os_log("Right joystick data")
                os_log("VelocityX = %f", joystickData.velocity.x)
                os_log("VelocityY = %f", joystickData.velocity.y)
                let data = String(format: "RIGHT %.2f %.2f\n", joystickData.velocity.x, joystickData.velocity.y)
                self.sendUDP(data.data(using: .utf8)!)
                self.rightVelocityX = joystickData.velocity.x
                self.rightVelocityY = joystickData.velocity.y
            }
        }
    }
    
    func startConnection() {
        self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
        self.connection?.start(queue: .global())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("UIViewController viewDidAppear")
        let hostString = UserDefaults.standard.string(forKey: "hostname")
        let hostPortString = UserDefaults.standard.string(forKey: "hostport")
        if (hostString == nil || hostPortString == nil) {
            openSettingsViewController()
            return
        }
        print("Configured with " + hostString! + ":" + hostPortString!)
        self.hostUDP = NWEndpoint.Host(hostString!)
        self.portUDP = NWEndpoint.Port(rawValue: UInt16(hostPortString!)!)!
        startConnection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("UIViewController viewDidDisappear")
    }
        
    @IBAction func walkButtonPressed(_ sender: UIButton) {
        walkButton.isSelected = !walkButton.isSelected
        let data = String(format: "WALK %d\n", walkButton.isSelected)
        self.sendUDP(data.data(using: .utf8)!)
    }
    
    @IBAction func activeButtonPressed(_ sender: UIButton) {
        activeButton.isSelected = !activeButton.isSelected
        if (activeButton.isSelected) {
            walkButton.isEnabled = true
        } else {
            walkButton.isEnabled = false
            walkButton.isSelected = false
            let data = String(format: "WALK %d\n", walkButton.isSelected)
            self.sendUDP(data.data(using: .utf8)!)
        }
        let data = String(format: "ACTIVE %d\n", sender.isSelected)
        self.sendUDP(data.data(using: .utf8)!)
    }
    
    @IBAction func settingsPressed(_ sender: UIButton) {
        print("Settings button pressed")
        openSettingsViewController()
    }
    
    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    
    func openSettingsViewController() {
        let settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        settingsViewController.modalPresentationStyle = .fullScreen
        self.present(settingsViewController, animated: true, completion: nil)
        }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

}
