//
//  PerformaceProcessor.swift
//  HealthBench
//
//  Created by Leon Nissen on 1/23/25.
//

import Foundation
import SwiftUI
import NotificationCenter


class PerformanceProcessor {
    static let shared = PerformanceProcessor()
    private let saveCount = Int(StorageKeys.performanceSaveInterval / StorageKeys.performanceLogInterval)
    
    private var timer: Timer?
    private var log: [PerformaceLog] = []
    
    
    
    
    func start() {
        timer = .scheduledTimer(withTimeInterval: StorageKeys.performanceLogInterval, repeats: true, block: log(_:))
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
    
    static var systemMetadata: Metadata {
        Metadata(
            device: deviceIdentifier,
            os: UIDevice.current.systemVersion,
            totalStorage: totalDiskSpace,
            freeStorage: freeDiskSpace,
            totalMemory: String(ProcessInfo.processInfo.physicalMemory)
        )
    }
    
    private func log(_ timer: Timer) {
        log.append(
            .init(
                timestamp: Date().timeIntervalSince1970,
                cpu: cpuUsage,
                memory: memoryUsage,
                thermalState: thermalState,
                batteryLevel: Double(UIDevice.current.batteryLevel),
                batteryState: batteryState
            )
        )
        
        if log.count >= saveCount {
            let tmp = log
            log.removeAll(keepingCapacity: true)
            PersistenceController.shared.savePerformace(tmp)
        }
    }
    
    private var thermalState: String {
        switch ProcessInfo.processInfo.thermalState {
        case .critical:
            return "critical"
        case .fair:
            return "fair"
        case .nominal:
            return "nominal"
        case .serious:
            return "serious"
        default:
            return "N/A"
        }
    }
    
    private var batteryState: String {
        switch UIDevice.current.batteryState {
        case .charging:
            return "charging"
        case .full:
            return "full"
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        default:
            return "N/A"
        }
    }
    
    private var cpuUsage: Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }
        
        if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                
                guard infoResult == KERN_SUCCESS else {
                    break
                }
                
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
                }
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return totalUsageOfCPU
    }
    
    private var memoryUsage: String {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        var used: UInt64 = 0
        if result == KERN_SUCCESS {
            used = UInt64(taskInfo.phys_footprint)
        }
        
        return String(used)
    }
    
    private static var deviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private static var totalDiskSpace: String {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else {
            return String(0)
        }
        return String(space)
    }
    
    private static var freeDiskSpace: String {
        if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String)
            .resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage {
            return String(space)
        } else {
            return String(0)
        }
    }
}
