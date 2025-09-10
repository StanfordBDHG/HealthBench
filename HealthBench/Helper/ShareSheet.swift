//
//  ShareSheet.swift
//  HealthyLLM
//
//  Created by Leon Nissen on 1/8/25.
//

import SwiftUI
import UIKit


struct ShareSheet: UIViewControllerRepresentable {
    let sharedURL: URL
    
    func makeUIViewController(context: Context) -> some UIActivityViewController {
        
        let controller = UIActivityViewController(
            activityItems: [sharedURL],
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: sharedURL)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
