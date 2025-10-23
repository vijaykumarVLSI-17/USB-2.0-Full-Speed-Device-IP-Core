# USB 2.0 Full-Speed Device Function IP Core
<img width="998" height="547" alt="image" src="https://github.com/user-attachments/assets/2579b103-c77e-433a-8e8a-03e8092b6436" />

### PHY Interface Layer — Rx Logic Implementation

**Status**: PHY Rx logic designed and verified (Full-Speed — 12 Mbps).

---

## 1. Project Overview
This document describes the **PHY Interface Layer — Rx logic** of a USB 2.0 Full-Speed Device IP Core.  
The Rx path converts differential USB line activity (D+/D−) into a clean byte stream and control signals consumed by the Protocol Layer packet parser.

**Scope of this doc:** implementation and verification details for the PHY Rx modules and the top-level wrapper `usb_phy_rx_wrapper`.

---

## 2. System Architecture Context


The `usb_phy_rx_wrapper` aggregates a set of small, well-defined Rx modules (listed below). The wrapper connects and sequences these modules to deliver `rx_data[7:0]`, `rx_valid`, `rx_active`, and `rx_eop` style signals to the upper layer.

---

## 3. Top-level Organization (module-based)
<img width="1260" height="567" alt="image" src="https://github.com/user-attachments/assets/5fdb4660-ce16-4e52-8076-ca1c3024fcc4" />

**Top module:** `usb_phy_rx_wrapper`  
This wrapper instantiates and wires the following modules (each implemented separately):
- **Line State / Sampler module**  
  - Purpose: Convert the analog PHY outputs / comparator samples into stable digital line-state signals and provide basic debounce/edge detection.

- **Bit Clock Recovery (BCR) module**  
  - Purpose: Generate a sampling clock (or sampling phase) aligned to bit timing for full-speed 12 Mbps operation. Provides a stable timing source for downstream bit extraction.

- **NRZI Decoder**  
  - Purpose: Convert NRZI-encoded serial transitions into raw bit stream (logical 1/0). Handles transition detection per USB encoding rules.

- **Bit Un-stuffer**  
  - Purpose: Remove stuffed bits that were inserted by the transmitter to prevent long runs of identical bits. Implements the USB bit-stuff rule (after six consecutive ones insert a zero).

- **SYNC Detector**  
  - Purpose: Detect the SYNC field pattern (the start-of-packet bit sequence) and align bit/byte boundaries for subsequent PID/byte extraction.

- **PID / Byte-align & Parser helper (small logic)**  
  - Purpose: After SYNC, group bits into bytes and deliver bytes to the Protocol Layer. Perform initial PID recognition (token/data/handshake).

- **EOP Detector**  
  - Purpose: Detect SE0/EOP conditions (End-Of-Packet) and assert `rx_eop` or an equivalent termination signal.

All modules are intentionally small and single-responsibility to improve testability and clarity.

---

## 4. Signal Interface (example / UTMI-like outputs)
Top-level outputs toward Protocol Layer (examples):
- `rx_data[7:0]` — byte-aligned received data
- `rx_valid` — pulse or handshake signaling rx_data is valid
- `rx_active` — indicates ongoing RX line activity (transaction in progress)
- `rx_eop` — end-of-packet indicator
- `rx_error` — optional: indicated malformed frames / bit-level errors

Inputs from PHY (examples):
- `dp`, `dn` — differential input lines or PHY sampled logic
- `phy_clk` / `sample_clk` — sampling clock from BCR
- reset, enable, and configuration signals

---

## 5. Design Rationale & Decisions

- **Modularity over monolithic FSMs:**  
  Each functionality is implemented as a focused module (NRZI, un-stuffer, SYNC detector, etc.). This improves testability and lets you reuse pieces or swap implementations (e.g., different clock recovery schemes).

- **Clear interface boundaries:**  
  Modules exchange simple handshakes/signals (bit streams, byte-ready pulses, eop). This helps isolate timing concerns (BCR/sampling) from byte-level logic.

- **Timing domains:**  
  The sampling/bit extraction logic uses a PHY-derived sampling clock (BCR). The byte/word interface to the protocol layer may cross clock domains — design with proper synchronization if the protocol layer uses a different clock.

- **Errors and responsibilities:**  
  This implementation focuses on bit-level correctness and packet boundary detection. CRC checks and higher-layer protocol validation are done in the Protocol Layer.

---

## 6. Verification Approach & Results

- **Unit tests per module:**  
  - Stimulus vectors for NRZI decoder (transitions/no-transitions), bit un-stuffer (various stuffed sequences), SYNC detection (offset SYNC patterns), and EOP detection (SE0 durations).
- **Integration test:**  
  - Feed complete USB full-speed packet bitstreams (token/data/handshake) through a PHY model into `usb_phy_rx_wrapper` and assert that the wrapper outputs correct `rx_data`, `rx_valid`, and `rx_eop` sequences.
- **Corner cases validated:**  
  - Long runs that require multiple stuffing events, back-to-back packets, EOP with minimal SE0, and out-of-alignment SYNC.
- **Result:** The Rx module set passes all full-speed simulation vectors used in verification. Waveform captures and testvectors can be added to the repo for reproducibility.
  

---

## 7. How to Read the Code (quick guide)
- `usb_phy_rx_wrapper.sv` — top-level wrapper (wires submodules together).  
- `nrzi_decoder.sv` — NRZI decode logic.  
- `bit_unstuffer.sv` — removes stuffed bits.  
- `bcr.sv` — bit clock recovery logic (sampling).  
- `sync_detector.sv` — finds SYNC field and aligns bytes.  
- `eop_detector.sv` — determines packet termination (SE0/EOP).

<img width="602" height="268" alt="image" src="https://github.com/user-attachments/assets/920a5cde-f020-4b99-83dd-f6e0e396b15f" />
<img width="602" height="281" alt="image" src="https://github.com/user-attachments/assets/e682cfee-5453-468f-8877-59ba37fbfcdc" />
<img width="602" height="291" alt="image" src="https://github.com/user-attachments/assets/e1bb18bf-917c-4d56-b449-e8481b587b6e" />



---

## 8. Next Steps
- Integrate with Protocol Layer packet parser (CRC checks, descriptor handling).  

---

## References
- USB 2.0 Specification (Chapters 7, 8, 9) — NRZI/bit-stuffing/packet formats.  
- OpenTitan `usbdev` — referenced as design inspiration and integration approach.

---
