//
// This source file is part of the Stanford Biodesign Digital Health HealthBench project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum StorageKeys {
    static let deleteModelWhenFinish = "deleteModelWhenFinish"
    static let finishedModels = "finishedModels"
    
    static let modelDirectory = "huggingface/models/mlx-community"
    static let modelFiles = ["*.safetensors", "config.json"]
    
    static let selectedModels = "selectedModels"
    static let onlySelectedCase = "onlySelectedCase"
    static let selectedCases = "selectedCase"
    
    static let maxOutputLength = "maxOutputLength"
    
    static let generatorModels: [String] = [
        "mlx-community/Bio-Medical-Llama-3-2-1B-CoT-012025",    // 1B = 4GB
        "mlx-community/Llama-3.2-1B-Instruct-4bit",             // 1B = 4GB
        "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit",     // 1.5B = 4GB
        
        "mlx-community/Llama-3.2-3B-Instruct-4bit",             // 3B = 6GB
        "mlx-community/Bio-Medical-3B-CoT-012025",              // 3B = 6GB
        "mlx-community/Phi-3-mini-4k-instruct-4bit",            // 3.8B = 4GB
        
        "mlx-community/DeepSeek-R1-Distill-Qwen-7B-4bit",       // 7B = 8GB
        "mlx-community/Qwen2-7B-Instruct-4bit",                 // 7B = 8GB
        
        "mlx-community/Bio-Medical-Llama-3-8B",                 // 8B = 8GB
        "mlx-community/Llama3.1-Aloe-Beta-8B",                  // 8B = 8GB
        "mlx-community/MedFound-Llama3-8B-finetuned",           // 8B = 8GB
        "mlx-community/medllama3-v20",                          // 8B = 8GB
        "mlx-community/Llama3-Med42-8B",                        // 8B = 8GB
        "mlx-community/Meta-Llama-3.1-8B-Instruct-4bit",        // 8B = 8GB
        "mlx-community/DeepSeek-R1-Distill-Llama-8B-4bit-mlx"   // 8B = 8GB
    ]
    
    static let performanceLogInterval = 0.5
    static let performanceSaveInterval = 5.0
}
