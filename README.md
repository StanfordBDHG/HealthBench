# Medicine on the Edge: On-Device LLM Benchmark 🏥📱

## Overview
This repository contains the codebase for benchmarking **on-device Large Language Models (LLMs)** for clinical reasoning. The study evaluates the feasibility, accuracy, and performance of **mobile LLM inference** using the **AMEGA medical benchmark dataset**.

## Abstract 📄
The deployment of Large Language Models (LLM) on mobile devices offers significant potential for medical applications, enhancing privacy, security, and cost-efficiency by eliminating reliance on cloud-based services and keeping sensitive health data local.
However, the performance and accuracy of on-device LLMs in real-world medical contexts remain underexplored.
In this study, we benchmark publicly available on-device LLMs using the AMEGA dataset, evaluating accuracy, computational efficiency, and thermal limitation across various mobile devices.
Our results indicate that compact general-purpose models like Phi-3 Mini achieve a strong balance between speed and accuracy, while medically fine-tuned models such as Med42 and Aloe attain the highest accuracy.
Notably, deploying LLMs on older devices remains feasible, with memory constraints posing a greater challenge than raw processing power.
Our study underscores the potential of on-device LLMs for healthcare while emphasizing the need for more efficient inference and models tailored to real-world clinical reasoning.

## Features
- **Benchmarking mobile LLMs** on real-world medical cases
- **Supports on-device execution** for Apple Silicon (iPhones & iPads)
- **Thermal and battery performance tracking**
- **Evaluation using AMEGA benchmark dataset**
- **SpeziLLM & MLX-based inference** for efficient on-device execution

## Selcted Models 🏆
- **Med42** 🏅 (Highest Accuracy)
- **Aloe 8B** 🏅 (Top-tier medical LLM)
- **Phi-3 Mini** ⚡ (Best balance of speed & accuracy)
- **DeepSeek R1** (Reasoning-focused LLM)
- **Llama & Qwen Variants** (General-purpose models)
- *and more*