Leaky-Integrate-and-Fire Neuron (SystemVerilog Implementation)

This project models a simplified biological LIF (Leaky-Integrate-and-Fire) neuron using digital hardware. The design is split into two main components:

A Datapath, which performs the numerical operations (integration, leakage, threshold comparison, reset).

A Controller, which sequences these operations using a small finite-state machine.

The goal is to emulate neuron behavior in a synthesizable hardware form suitable for FPGA acceleration or neuromorphic computing experiments.

Features

Fully parameterized SystemVerilog modules

Register-based datapath with load/enable signals

Threshold comparison and spike generation

Leakage and integration control

Clean separation between control logic and arithmetic units

Synchronous, synthesizable design

How the Design Works
Datapath

The datapath includes:

Parameterized registers (Reg #(WIDTH))

Accumulation logic for membrane potential

Leakage path

Muxes controlled by the FSM

Comparator for Vmem >= Vth

Output spike flag

The datapath holds and updates the internal neuron state each clock cycle.

Controller

The controller is a small FSM that:

Loads initial values

Selects between leakage & integration inputs

Updates membrane potential

Checks threshold

Fires a spike if needed

Resets the neuron

It drives all mux-select and load-enable signals for the datapath.

Simulation

You can simulate using any SystemVerilog-compatible simulator:

Example (ModelSim / Questa)
vlog dataPath.sv controller.sv tb.sv
vsim work.tb
run -all

Example (Verilator)
verilator --cc controller.sv dataPath.sv --exe tb.cpp
make -C obj_dir -f Vcontroller.mk
./obj_dir/Vcontroller

Parameters

WIDTH – bit-width for neuron state registers

Initial membrane value

Leakage constant

Integration constant

Threshold voltage

These can be modified in the datapath to experiment with neuron behavior.

Applications

Neuromorphic computing

Digital neuron simulations

FPGA-based neural accelerators

Exploring spiking neuron dynamics

Teaching computer architecture / digital design concepts

Author

Kian Fotovat

Computer Architecture Project
