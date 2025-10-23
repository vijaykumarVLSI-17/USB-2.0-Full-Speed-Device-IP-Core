# USB-2.0-Full-Speed-Device-IP-Core
## Project Goal
<img width="998" height="547" alt="image" src="https://github.com/user-attachments/assets/ef0032ff-61e3-4715-ac3b-3d64af92f936" />

Implement a modular **USB 2.0 Full-Speed Device Function IP Core** as shown in the block diagram.

### Main objectives
- **Design all key modules**: Protocol Engine, TX Logic, RX Logic, USB PHY Interface Layer, Buffer Memory, Memory Arbiter, Control/Status Registers, and Bus Interface.  
- **Enable USB communication**: Handle packet transmission and reception between device and host at full speed (12 Mbps).  
- **Build modular RTL code**: Each block is developed as a separate, reusable module for easy testing and integration.  
- **Provide clean interfaces**: Use standard UTMI-style signals between the logic and PHY layer, and simple buses for memory and register access.  
- **Verify functionality**: Create testbenches for unit and integration tests, ensuring correct operation for all USB packet types and corner cases.

### Outcome
A working, synthesizable USB 2.0 device IP core, ready for FPGA or SoC integration, with full documentation and verification artifacts.

---
