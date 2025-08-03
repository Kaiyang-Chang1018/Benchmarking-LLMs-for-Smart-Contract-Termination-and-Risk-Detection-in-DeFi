# DeFi Smart Contract Datasets

This repository contains four complementary datasets of Ethereum smart contracts, curated for research on DeFi analysis, vulnerability detection, kill-switch patterns, and LLM-based functional classification.

---

## Table of Contents

1. [Dataset 1: Etherscan Verified Smart Contracts]
2. [Dataset 2: Benchmark for Evaluating LLMs on DeFi Contracts]
3. [Dataset 3: RE-based Kill-switch Contract Dataset]
4. [Dataset 4: LLM-Based Functional Classification of DeFi Contracts]
---

## Dataset 1: Etherscan Verified Smart Contracts

* **Description**: A collection of 200,000 verified Ethereum contracts deployed between January 2023 and April 1, 2025. Retrieved via Google BigQuery and the Etherscan API.
* **Contents**:

  * `dataset1/`: Directory of source files for \~200,000 verified contracts.
* **Purpose**: Provides a comprehensive baseline for smart contract analysis and DeFi research.

---

## Dataset 2: Benchmark for Evaluating LLMs on DeFi Contracts

* **Description**: 100 hand-curated smart contracts spanning 9 DeFi domains:

  * Lending, NFT Finance, Asset Management, Oracles, GameFi, Trading, Interoperability, Governance, Payments.
* **Annotations**:

  * **Vulnerabilities**: 210 high‑risk issues labeled via Slither and Mythril.
  * **Termination Mechanisms**: 31 contracts with pause/stop or self‑destruct or proxy admin patterns.
* **Contents**:

  * `dataset2/contracts/`: Solidity files of the 100 contracts.
  * `dataset2/annotations/`: JSON annotations for vulnerabilities and termination logic.
* **Purpose**: Serves as a domain‑focused testbed for LLM vulnerability detection and reasoning.

---

## Dataset 3: RE-based Kill-switch Contract Dataset

* **Description**: Smart contracts from Dataset 1 analyzed for termination-related patterns using regular expressions and structural matching.
* **Statistics**:

  * Selfdestruct: 34 contracts
  * Emergency Stop: 3,421 contracts
  * Proxy Pattern: 44,340 contracts
* **Invocation Analysis**:

  * Selfdestruct used 34 times
  * Emergency Stop used 2,329 times
  * Proxy Upgrade used 16,649 times
* **Contents**:
* 
  * `dataset3/selfdestruct/`, `dataset3/emergency_stop/`, `dataset3/proxy/`: Source files matched by pattern.
* **Purpose**: Enables study of real-world kill‑switch adoption and usage trends.

---

## Dataset 4: LLM-Based Functional Classification of DeFi Contracts

* **Description**: Functional labels for each of the \~200,000 verified contracts in Dataset 1, assigned via the Qwen3-30B-A3B-Instruct-2507 model.
* **Categories (15)**: Trading, Lending, Stable Assets, Asset Management, Insurance, NFTFi, GameFi, Payments, Oracles, Interoperability, Identity, Governance Tooling, Privacy & Security, Data Storage, Other.
* **Contents**:

  * `dataset4/{category}/`: Directories grouping source files by category.
* **Purpose**: Supports targeted analysis, risk metrics, and category-specific tool development.

---
