//
//  ViewController.swift
//  Sensor
//
//  Created by Tamara Erlij on 17/06/19.
//  Copyright © 2019 Tamara Erlij. All rights reserved.
//

import UIKit
import CoreMotion
import Dispatch


class ViewController: UIViewController {
    
    //   Declarar as variáveis:
    //     CMMotionActivityManager: An object that manages access to the motion data stored by the device.
    //     CMPedometer: An object for fetching the system-generated live walking data.
    private let contagemDePassos = CMMotionActivityManager()
    private let pedometro = CMPedometer()
    private var shouldStartUpdating: Bool = false
    private var dataDeInicio: Date? = nil
    
    
    @IBOutlet weak var contagemDePassosLabel: UILabel!
    
    @IBOutlet weak var tipoDeAtividadeLabel: UILabel!
    
    @IBOutlet weak var startBotao: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Com uma target-action, você manda uma mensagem (a ação) para um objeto (target)
        // target é self
        
        startBotao.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let dataDeInicio = dataDeInicio else { return }
        updateStepsCountLabelUsing(dataDeInicio : dataDeInicio)
    }
    
    @objc private func didTapStartButton() {
        shouldStartUpdating = !shouldStartUpdating
        shouldStartUpdating ? (onStart()) : (onStop())
    }
}


extension ViewController {
    private func onStart() {
        startBotao.setTitle("pare", for: .normal)
        dataDeInicio = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    
    private func onStop() {
        startBotao.setTitle("Start", for: .normal)
        dataDeInicio = nil
        stopUpdating()
    }
    
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
        } else {
            tipoDeAtividadeLabel.text = "Não está disponível"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            contagemDePassosLabel.text = "Não está disponível"
        }
    }
    
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            tipoDeAtividadeLabel.text = "Não está disponível"
            contagemDePassosLabel.text = "Não está disponível"
        default:break
        }
    }
    
    private func stopUpdating() {
        contagemDePassos.stopActivityUpdates()
        pedometro.stopUpdates()
        pedometro.stopEventUpdates()
    }
    
    private func on(error: Error) {
        //handle error
    }
    
    private func updateStepsCountLabelUsing(dataDeInicio: Date) {
        pedometro.queryPedometerData(from: dataDeInicio, to: Date()) {
            [weak self] pedometerData, error in
            if let error = error {
                self?.on(error: error)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.contagemDePassosLabel.text = String(describing: pedometerData.numberOfSteps)
                }
            }
        }
    }
    
    private func startTrackingActivityType() {
        contagemDePassos.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.tipoDeAtividadeLabel.text = "Andando"
                } else if activity.stationary {
                    self?.tipoDeAtividadeLabel.text = "Parado"
                } else if activity.running {
                    self?.tipoDeAtividadeLabel.text = "Correndo"
                } else if activity.automotive {
                    self?.tipoDeAtividadeLabel.text = "Automóvel"
                }
            }
        }
    }
    
    private func startCountingSteps() {
        pedometro.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.contagemDePassosLabel.text = pedometerData.numberOfSteps.stringValue
            }
        }
    }
}



