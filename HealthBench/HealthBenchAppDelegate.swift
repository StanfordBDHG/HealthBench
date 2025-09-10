//
//  HealthBenchAppDelegate.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation
import Spezi
import SpeziLLM
import SpeziLLMLocal

class HealthBenchAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            LLMRunner {
                LLMLocalPlatform()
            }
            BenchmarkProcessor()
        }
    }
}
