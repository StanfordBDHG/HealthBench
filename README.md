<!--
This source file is part of the Stanford Biodesign Digital Health HealthBench project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

# Medicine on the Edge: On-Device LLM Benchmark

[![Build and Test](https://github.com/StanfordBDHG/HealthBench/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordBDHG/HealthBench/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordBDHG/HealthBench/graph/badge.svg?token=Nhpd0BiuU8)](https://codecov.io/gh/StanfordBDHG/HealthBench)


## Overview

This repository contains the codebase for benchmarking **on-device Large Language Models (LLMs)** for clinical reasoning. The study evaluates the feasibility, accuracy, and performance of **mobile LLM inference** using the **AMEGA medical benchmark dataset**.

The deployment of Large Language Models (LLM) on mobile devices offers significant potential for medical applications, enhancing privacy, security, and cost-efficiency by eliminating reliance on cloud-based services and keeping sensitive health data local.
However, the performance and accuracy of on-device LLMs in real-world medical contexts remain underexplored.
In this study, we benchmark publicly available on-device LLMs using the AMEGA dataset, evaluating accuracy, computational efficiency, and thermal limitation across various mobile devices.
Our results indicate that compact general-purpose models like Phi-3 Mini achieve a strong balance between speed and accuracy, while medically fine-tuned models such as Med42 and Aloe attain the highest accuracy.
Notably, deploying LLMs on older devices remains feasible, with memory constraints posing a greater challenge than raw processing power.
Our study underscores the potential of on-device LLMs for healthcare while emphasizing the need for more efficient inference and models tailored to real-world clinical reasoning.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordBDHG/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordBDHG/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordBDHG/PediatricAppleWatchStudy/tree/main/LICENSES) for more information.


## Our Research

For more information, check out our website at [biodesigndigitalhealth.stanford.edu](https://biodesigndigitalhealth.stanford.edu).

![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-light.png#gh-light-mode-only)
![Stanford Byers Center for Biodesign Logo](https://raw.githubusercontent.com/StanfordBDHG/.github/main/assets/biodesign-footer-dark.png#gh-dark-mode-only)
