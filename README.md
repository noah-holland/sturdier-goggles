# sturdy-goggles
Repository for all things ECE 552


## Project 2

#### Checklist
Mark with `[initial]` when in progress. Change to `[x]` when completed.
Feel free to add more tasks as needed.

#### Pipeline Registers
- Registers must handle the synchronous 'rst_n' signal
- Registers must not update when 'stall' is asserted
- Registers must change the instruction to a NOP (all 0's) when 'flush' is asserted
- Registers must support bypassing/forwarding (or do this somewhere else?)
- [ ] IF/ID Register
- [ ] ID/EX Register
- [ ] EX/MEM Register (it is in the wrong location on the PDF)
- [ ] MEM/WB Register (it is in the wrong location on the PDF)

#### Control Logic
- [ ] Global 'stall' signal
- [R] Global 'flush' signal
- [R] Global 'halt' signal (may need to be changed from P1's implementation)

#### Miscellaneous
- [R] Make sure the PC updates/pauses at the correct times


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
- [X] Shifter

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
