vlog -sv ALU.v Branch.v Control_Unit_Top.v Data_Memory.v Decode_Cycle.v Fetch_Cycle.v Hazard_unit.v Instruction_Memory.v Memory_Cycle.v Execute_Cycle.v PC.v Register_File.v Sign_Extend.v Writeback_Cycle.v core.v top.v pipeline_tb.sv
vsim -voptargs=+acc tb
add wave -r *
run -all