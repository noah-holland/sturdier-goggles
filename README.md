# sturdy-goggles
Repository for all things ECE 552

## Project 1

#### Checklist
Mark with `[initial]` when in progress change to `[x]` when completed. Feel free to add more tasks as needed.

##### CPU Desgin
- [R] cpu.v

##### ALU
- [ ] alu.v
	- Notes from Ryan for whoever works on alu.v:
		- For LW and SW instructions, the operation should perform: src_data_1 + (immediate << 1) to calculate the memory address
		- Implementing the control logic inside the ALU would be best in my opinion, but whoever works on it can do whatever
- [x] CLA
- [N] Saturation module
- [ ] RED
- [ ] PADDSB
- [ ] Shifter

##### Memory
- [x] LWSW
	- Done in cpu.v
- [x] LHB/LLB (may be similar)
	- Done in cpu.v

##### Control
- [ ] General cotnrol
- [R] pc\_register.v
	- Includes a register to store the PC
	- Includes logic to update the PC each clock cycle
- [R] Branch/Branch Register
	- Done in pc\_register.v
- [x] PCS
	- Done in cpu.v
- [R] HLT
	- Done in pc\_register.v
