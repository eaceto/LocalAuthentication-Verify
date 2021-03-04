//
//  main.swift
//  TouchIDCLI
//
//  Created by Kimi on 04/03/2021.
//

import Foundation
import LocalAuthentication

private class LocalAuthenticationCLI {
    
    let context: LAContext
    var args: [String]
    
    init(args: [String]) {
        self.args = args
        
        context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 0
    }
    
    public func run() {
        guard let command = Command.parse(from: args) else {
            return
        }
        switch command {
        case .supports(policy: let policy):
            let (supports, error) = supportsLocalAuthentication(with: policy)
            
            if supports && error == nil {
                print("Supported")
                exit(EXIT_SUCCESS)
            }
            
            let errorDescription = error?.localizedDescription ?? "Unknown error"
            print("Unsupported: \(errorDescription)")
            exit(EXIT_FAILURE)
        
        case .authenticate(with: let policy):
            var (supports, error) = supportsLocalAuthentication(with: policy)
            var policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
            
            if let laError = error {
                switch laError {
                case LAError.biometryLockout, LAError.biometryNotEnrolled, LAError.biometryNotAvailable, LAError.watchNotAvailable:
                    supports = true
                    policy = .deviceOwnerAuthentication
                    error = nil
                default:
                    break
                }
            }
            
            guard supports == true && error == nil else {
                let errorDescription = error?.localizedDescription ?? "Unknown error"
                print("Unsupported: \(errorDescription)")
                exit(EXIT_FAILURE)
                break
            }
            
            authenticate(with: policy) { success, error in
                if success && error == nil {
                    print("Authenticated")
                    exit(EXIT_SUCCESS)
                }
                
                let errorDescription = error?.localizedDescription ?? "Unknown error"
                print("Unauthenticated: \(errorDescription)")
                exit(EXIT_FAILURE)
            }
            dispatchMain()
        }
    }
    
    
    fileprivate func supportsLocalAuthentication(with policy: LAPolicy) -> (Bool, Error?) {
        var error: NSError?
        let supportsAuth = context.canEvaluatePolicy(policy, error: &error)
        return (supportsAuth, error)
    }

    fileprivate func authenticate(with policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics, callback: @escaping (Bool, Error?) -> Void) {
        let reason = "validate your user's session."
        context.evaluatePolicy(policy, localizedReason: reason, reply: callback)
    }

}

private enum Command {
    case supports(policy: LAPolicy = LAPolicy.deviceOwnerAuthentication)
    case authenticate(with: LAPolicy = LAPolicy.deviceOwnerAuthentication)
    
    public static func with(command: String, options: [String]) -> Command? {
        switch command {
        case "-s", "--supports":
            return .supports(policy: options.map { option in
                if option == "withBiometrics" { return LAPolicy.deviceOwnerAuthenticationWithBiometrics }
                if option == "withBiometricsOrWatch" { return LAPolicy.deviceOwnerAuthenticationWithBiometricsOrWatch }
                if option == "withWatch" { return LAPolicy.deviceOwnerAuthenticationWithWatch }
                return .deviceOwnerAuthentication
            }.first ?? .deviceOwnerAuthentication)
        case "-a", "--authenticate":
            return .authenticate(with: options.map { option in
                if option == "withBiometrics" { return LAPolicy.deviceOwnerAuthenticationWithBiometrics }
                if option == "withBiometricsOrWatch" { return LAPolicy.deviceOwnerAuthenticationWithBiometricsOrWatch }
                if option == "withWatch" { return LAPolicy.deviceOwnerAuthenticationWithWatch }
                return .deviceOwnerAuthentication
            }.first ?? .deviceOwnerAuthentication)
        default:
            return nil
        }
    }
    
    public static func parse(from args: [String]) -> Command? {
        guard let command = args.first else { return nil }
        
        return Command.with(command: command, options: args.dropFirst().map { String($0) })
    }
}

let args = CommandLine.arguments.dropFirst().map { String($0) }
LocalAuthenticationCLI(args: args).run()
