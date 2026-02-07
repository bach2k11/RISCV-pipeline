module tb;

    reg clk;
    reg rst_n;
    wire [31:0] RD;
    wire MemWriteM;
    wire [31:0] ReadDataM;
    wire [31:0] WriteDataM;

    integer pc_change_count; // Biến đếm số lần PCF thay đổi
    reg [31:0] prev_pcf; 
    integer total_error;

parameter CLOCK_CYCLE = 2;

initial clk = 0;
always #(CLOCK_CYCLE/2) clk = ~clk;

    top DUT (
        .clk(clk), 
        .rst(rst_n),
        .RD(RD),
        .MemWriteM(MemWriteM),
        .ReadDataM(ReadDataM),
        .WriteDataM(WriteDataM)
    );
integer i;
task reset_register_file();
    begin
        for (i = 0; i < 32; i = i + 1) begin
            DUT.core.Decode.rf.Register[i] = 32'b0;
        end
    end
endtask

task reset_imem();
    begin
        for (i = 0; i < 1024; i = i + 1) begin
            DUT.imem.mem[i] = 32'bx;
        end
    end
endtask

reg [31:0] golden_register_file [31:0];
// Thêm logic đếm số lần PCF thay đổi
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc_change_count <= 0;
        prev_pcf <= 32'b0; // Khởi tạo giá trị PCF trước đó
    end else begin
        if (DUT.core.PCF !== prev_pcf) begin
            pc_change_count <= pc_change_count + 1;
            prev_pcf <= DUT.core.PCF; // Cập nhật giá trị PCF trước đó
        end
    end
end


task R_type_instruction();
    integer error_count;
    integer cycle;
    begin
        error_count = 0;
        cycle = 1;
        rst_n = 0;
        #(CLOCK_CYCLE);
        @(negedge clk) rst_n = 1;
        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/R-type/IMEM_hex.txt", DUT.imem.mem);
        reset_register_file();
        $display("%t Starting R-type instruction test...", $time);

        wait(DUT.core.Instruct_tb !== 32'hx);
        @(posedge clk);
        while(DUT.core.Instruct_tb !== 32'hx) begin
            cycle = cycle + 1;
            #(CLOCK_CYCLE/2);
            @(negedge clk) if((DUT.core.Instruct_tb === 32'hx)&& (DUT.core.Decode.rf.Register[15])&&(DUT.core.Decode.rf.Register[16] == 0)) break;
            #(CLOCK_CYCLE/2);
            if(cycle > 100) begin
                $display("Test R-type instruction failed! (Time out)");
                $finish;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/R-type/golden_register_file_hex.txt", golden_register_file);
        for ( i = 0; i < 32; i = i + 1) begin
            if (DUT.core.Decode.rf.Register[i] !== golden_register_file[i]) begin
                $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.core.Decode.rf.Register[i], golden_register_file[i]);
                error_count = error_count + 1;
            end
        end

        if(error_count == 0) begin
            $display("%t R-type instruction test passed!", $time);
        end else begin
            $display("%t R-type instruction test failed with %0d errors.",$time, error_count);
            total_error = total_error + error_count;
        end
        reset_register_file();
        reset_imem();
        // $finish; 
    end
endtask

// task I_type_arithmetic_instruction();
//     integer error_count;
//     integer cycle;
//     integer extra_cycle;
//     begin
//         error_count = 0;
//         cycle = 1;
//         rst_n = 0;
//         #(CLOCK_CYCLE);
//         @(negedge clk) rst_n = 1;
//         $readmemh("/home/bach/workspace/pipeline_ver1/r32i/I-type(arithmetic&logic)/IMEM_hex.txt", DUT.imem.mem);
//         reset_register_file();
//         $display("%t Starting I-type arithmetic instruction test...", $time);

//         wait(DUT.core.Instruct_tb !== 32'hx);
//         @(posedge clk);
//         while(DUT.core.Instruct_tb !== 32'hx) begin
//             cycle = cycle + 1;
//             #(CLOCK_CYCLE/2);
//             @(negedge clk) if(DUT.core.Instruct_tb === 32'hx) begin
//                 extra_cycle = 3;
//                 while(extra_cycle > 0) begin
//                     @(posedge clk);
//                     extra_cycle = extra_cycle - 1;
//                 end
//                 break;
//             end
//             #(CLOCK_CYCLE/2);
//             if(cycle > 100) begin
//                 $display("Test I-type arithmetic & logic instruction failed! (Time out)");
//                 $finish;
//             end
//         end

//         $readmemh("/home/bach/workspace/pipeline_ver1/r32i/I-type(arithmetic&logic)/golden_register_file_hex.txt", golden_register_file);
//         for (int i = 0; i < 32; i = i + 1) begin
//             if (DUT.core.Decode.rf.Register[i] !== golden_register_file[i]) begin
//                 $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.core.Decode.rf.Register[i], golden_register_file[i]);
//                 error_count = error_count + 1;
//             end
//         end

//         if(error_count == 0) begin
//             $display("%t I-type arithmetic instruction test passed!", $time);
//         end else begin
//             $display("%t I-type arithmetic instruction test failed with %0d errors.",$time, error_count);
//             total_error = total_error + error_count;
//         end
//         reset_register_file();
//         reset_imem();
//         // $finish; 
//     end
// endtask

task I_type_load_instruction();
    integer error_count;
    integer cycle;
    begin
        error_count = 0;
        cycle = 1;
        rst_n = 0;
        #(CLOCK_CYCLE);
        @(negedge clk) rst_n = 1;
        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/I-type(load)/IMEM_hex.txt", DUT.imem.mem);
        reset_register_file();
        $display("%t Starting I-type load instruction test...", $time);

        wait(DUT.core.Instruct_tb !== 32'hx);
        @(posedge clk);
        while(DUT.core.Instruct_tb !== 32'hx) begin
            cycle = cycle + 1;
            #(CLOCK_CYCLE/2);
            @(negedge clk) if(DUT.core.Instruct_tb === 32'hx) break;
            #(CLOCK_CYCLE/2);
            if(cycle > 100) begin
                $display("Test I-type load failed! (Time out)");
                $finish;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/I-type(load)/golden_register_file_hex.txt", golden_register_file);
        for (int i = 0; i < 32; i = i + 1) begin
            if (DUT.core.Decode.rf.Register[i] !== golden_register_file[i]) begin
                $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.core.Decode.rf.Register[i], golden_register_file[i]);
                error_count = error_count + 1;
            end
        end

        if(error_count == 0) begin
            $display("%t I-type load instruction test passed!", $time);
        end else begin
            $display("%t I-type load instruction test failed with %0d errors.",$time, error_count);
            total_error = total_error + error_count;
        end
        reset_register_file();
        reset_imem();
        // $finish; 
    end
endtask

task S_type_instruction();
    integer error_count;
    integer cycle;
    integer i;
    integer mem_data [0:63];
    begin
        error_count = 0;
        cycle = 1;
        rst_n = 0;
        #(CLOCK_CYCLE);
        @(negedge clk) rst_n = 1;
        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/S-type/IMEM_hex.txt", DUT.imem.mem);
        reset_register_file();
        $display("%t Starting S-type instruction test...", $time);

        wait(DUT.core.Instruct_tb !== 32'hx);
        @(posedge clk);
        while(DUT.core.Instruct_tb !== 32'hx) begin
            cycle = cycle + 1;
            #(CLOCK_CYCLE/2);
            @(negedge clk) if(DUT.core.Instruct_tb === 32'hx) break;
            #(CLOCK_CYCLE/2);
            if(cycle > 100) begin
                $display("Test S-type failed! (Time out)");
                $finish;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/S-type/golden_register_file_hex.txt", golden_register_file);
        for (int i = 0; i < 32; i = i + 1) begin
            if (DUT.core.Decode.rf.Register[i] !== golden_register_file[i]) begin
                $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.core.Decode.rf.Register[i], golden_register_file[i]);
                error_count = error_count + 1;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/r32i/S-type/golden_DMEM_hex.txt", mem_data);
        i = 0;
        while(DUT.dmem.mem[i] !== 32'hx) begin
            if (DUT.dmem.mem[i] !== mem_data[i]) begin
                $display("Mismatch at memory address %0d: DUT = %h, Golden = %h", i, DUT.dmem.mem[i], mem_data[i]);
                error_count = error_count + 1;
            end
            i = i + 1;
        end


        if(error_count == 0) begin
            $display("%t S-type instruction test passed!", $time);
        end else begin
            $display("%t S-type instruction test failed with %0d errors.",$time, error_count);
            total_error = total_error + error_count;
        end
        reset_register_file();
        reset_imem();
        // $finish; 
    end
endtask

// task JAL_instruction();
//     integer error_count;
//     integer cycle;
//     begin
//         error_count = 0;
//         cycle = 1;
//         rst_n = 0;
//         #(CLOCK_CYCLE);
//         @(negedge clk) rst_n = 1;
//         $readmemh("./Single_Cycle_test/J-type/IMEM_hex.txt", DUT.Fetch.IMEM.mem);
//         reset_register_file();
//         $display("%t Starting JAL instruction test...", $time);

//         wait(DUT.Instruct_tb !== 32'hx);
//         @(posedge clk);
//         while(DUT.Instruct_tb !== 32'hx) begin
//             cycle = cycle + 1;
//             #(CLOCK_CYCLE/2);
//             @(negedge clk) if(DUT.Instruct_tb === 32'hx) break;
//             #(CLOCK_CYCLE/2);
//             if(cycle > 100) begin
//                 $display("Test JAL failed! (Time out)");
//                 $finish;
//             end
//         end

//         $readmemh("./Single_Cycle_test/J-type/golden_register_file_hex.txt", golden_register_file);
//         for (int i = 0; i < 32; i = i + 1) begin
//             if (DUT.Decode.rf.Register[i] !== golden_register_file[i]) begin
//                 $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.Decode.rf.Register[i], golden_register_file[i]);
//                 error_count = error_count + 1;
//             end
//         end

//         if(error_count == 0) begin
//             $display("%t JAL instruction test passed!", $time);
//         end else begin
//             $display("%t JAL instruction test failed with %0d errors.",$time, error_count);
//             total_error = total_error + error_count;
//         end
//         reset_register_file();
//         reset_imem();
//         // $finish; 
//     end
// endtask

// task B_type_instruction();
//     integer error_count;
//     integer cycle;
//     begin
//         error_count = 0;
//         cycle = 1;
//         rst_n = 0;
//         #(CLOCK_CYCLE);
//         @(negedge clk) rst_n = 1;
//         $readmemh("./Single_Cycle_test/B-type/IMEM_hex.txt", DUT.Fetch.IMEM.mem);
//         reset_register_file();
//         $display("%t Starting B-type instruction test...", $time);

//         wait(DUT.Instruct_tb !== 32'hx);
//         @(posedge clk);
//         while(DUT.Instruct_tb !== 32'hx) begin
//             cycle = cycle + 1;
//             #(CLOCK_CYCLE/2);
//             @(negedge clk) if(DUT.Instruct_tb === 32'hx) break;
//             #(CLOCK_CYCLE/2);
//             if(cycle > 100) begin
//                 $display("Test B-type failed! (Time out)");
//                 $finish;
//             end
//         end

//         $readmemh("./Single_Cycle_test/B-type/golden_register_file_hex.txt", golden_register_file);
//         for (int i = 0; i < 32; i = i + 1) begin
//             if (DUT.Decode.rf.Register[i] !== golden_register_file[i]) begin
//                 $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.Decode.rf.Register[i], golden_register_file[i]);
//                 error_count = error_count + 1;
//             end
//         end

//         if(error_count == 0) begin
//             $display("%t B-type instruction test passed!", $time);
//         end else begin
//             $display("%t B-type instruction test failed with %0d errors.",$time, error_count);
//             total_error = total_error + error_count;
//         end
//         reset_register_file();
//         reset_imem();
//         // $finish; 
//     end
// endtask

// task JALR_instruction();    
//     integer error_count;
//     integer cycle;
//     begin
//         error_count = 0;
//         cycle = 1;
//         rst_n = 0;
//         #(CLOCK_CYCLE);
//         @(negedge clk) rst_n = 1;
//         $readmemh("./Single_Cycle_test/I-type(JALR)/IMEM_hex.txt", DUT.Fetch.IMEM.mem);
//         reset_register_file();
//         $display("%t Starting JALR instruction test...", $time);

//         wait(DUT.Instruct_tb !== 32'hx);
//         @(posedge clk);
//         while(DUT.Instruct_tb !== 32'hx) begin
//             cycle = cycle + 1;
//             #(CLOCK_CYCLE/2);
//             @(negedge clk) if(DUT.Instruct_tb === 32'hx) break;
//             #(CLOCK_CYCLE/2);
//             if(cycle > 100) begin
//                 $display("Test JALR failed! (Time out)");
//                 $finish;
//             end
//         end

//         $readmemh("./Single_Cycle_test/I-type(JALR)/golden_register_file_hex.txt", golden_register_file);
//         for (int i = 0; i < 32; i = i + 1) begin
//             if (DUT.Decode.rf.Register[i] !== golden_register_file[i]) begin
//                 $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.Decode.rf.Register[i], golden_register_file[i]);
//                 error_count = error_count + 1;
//             end
//         end

//         if(error_count == 0) begin
//             $display("%t JALR instruction test passed!", $time);
//         end else begin
//             $display("%t JALR instruction test failed with %0d errors.",$time, error_count);
//             total_error = total_error + error_count;
//         end
//         reset_register_file();
//         reset_imem();
//         // $finish; 
//     end
// endtask

// task U_type_instruction();
//     integer error_count;
//     integer cycle;
//     begin
//         error_count = 0;
//         cycle = 1;
//         rst_n = 0;
//         #(CLOCK_CYCLE);
//         @(negedge clk) rst_n = 1;
//         $readmemh("./Single_Cycle_test/U-type/IMEM_hex.txt", DUT.Fetch.IMEM.mem);
//         reset_register_file();
//         $display("%t Starting U-type instruction test...", $time);

//         wait(DUT.Instruct_tb !== 32'hx);
//         @(posedge clk);
//         while(DUT.Instruct_tb !== 32'hx) begin
//             cycle = cycle + 1;
//             #(CLOCK_CYCLE/2);
//             @(negedge clk) if(DUT.Instruct_tb === 32'hx) break;
//             #(CLOCK_CYCLE/2);
//             if(cycle > 100) begin
//                 $display("Test U-type failed! (Time out)");
//                 $finish;
//             end
//         end

//         $readmemh("./Single_Cycle_test/U-type/golden_register_file_hex.txt", golden_register_file);
//         for (int i = 0; i < 32; i = i + 1) begin
//             if (DUT.Decode.rf.Register[i] !== golden_register_file[i]) begin
//                 $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.Decode.rf.Register[i], golden_register_file[i]);
//                 error_count = error_count + 1;
//             end
//         end

//         if(error_count == 0) begin
//             $display("%t U-type instruction test passed!", $time);
//         end else begin
//             $display("%t U-type instruction test failed with %0d errors.",$time, error_count);
//             total_error = total_error + error_count;
//         end
//         reset_register_file();
//         reset_imem();
//         // $finish; 
//     end
// endtask

task bubble();
    integer error_count;
    integer cycle;
    integer i;
    integer mem_data [0:63];
    begin
        error_count = 0;
        cycle = 1;
        rst_n = 0;
        #(CLOCK_CYCLE);
        @(negedge clk) rst_n = 1;
        $readmemh("/home/bach/workspace/pipeline_ver1/bubble/machine_code.txt", DUT.imem.mem);
        reset_register_file();
        $display("%tns Starting program sort instruction test...", $time);

        wait(DUT.core.Instruct_tb !== 32'hx);
        @(posedge clk);
        while(DUT.core.Instruct_tb !== 32'hx) begin
            cycle = cycle + 1;
            #(CLOCK_CYCLE/2);
            @(negedge clk) if(DUT.core.Instruct_tb === 32'hx) break;
            #(CLOCK_CYCLE/2);
            if(cycle > 100) begin
                $display("Test program sort failed! (Time out)");
                $finish;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/bubble/regdump.txt", golden_register_file);
        for (int i = 0; i < 32; i = i + 1) begin
            if (DUT.core.Decode.rf.Register[i] !== golden_register_file[i]) begin
                $display("Mismatch at register x%0d: DUT = %h, Golden = %h", i, DUT.core.Decode.rf.Register[i], golden_register_file[i]);
                error_count = error_count + 1;
            end
        end

        $readmemh("/home/bach/workspace/pipeline_ver1/bubble/memdump.txt", mem_data);
        i = 0;
        while(DUT.dmem.mem[i] !== 32'hx) begin
            if (DUT.dmem.mem[i] !== mem_data[i]) begin
                $display("Mismatch at memory address %0d: DUT = %h, Golden = %h", i, DUT.dmem.mem[i], mem_data[i]);
                error_count = error_count + 1;
            end
            i = i + 1;
        end


        if(error_count == 0) begin
            $display("%tns program sort instruction test passed!", $time);
        end else begin
            $display("%t program sort instruction test failed with %0d errors.",$time, error_count);
            total_error = total_error + error_count;
        end
        reset_register_file();
        reset_imem();
        // $finish; 
    end
endtask

initial begin
    
    total_error = 0;   pc_change_count = 0; // Khởi tạo biến đếm PCF
    bubble();

    //R_type_instruction();
     //I_type_arithmetic_instruction();
     //S_type_instruction(); // Prerequisite for I_type_load_instruction test
     //I_type_load_instruction();
    // JALR_instruction();
    // JAL_instruction();
    // B_type_instruction();
    // U_type_instruction();
    $display("Total instruction execute: %0d", pc_change_count); // Hiển thị số lần PCF thay đổi

    $display("Total error count: %0d", total_error);
   // #(100*CLOCK_CYCLE);

    if(total_error == 0)begin
        $display("\n");

        $display(" **********************************************");   
        $display(" *****************************                *");
        $display(" **                         **       |\__||    *");
        $display(" **   Congratulations !!    **      / O.O  |  *");
        $display(" **                         **    /_____   |  *");
        $display(" ** RV32I Simulation PASS!! **   /^ ^ ^ \\  |  *");
        $display(" **                         **  |^ ^ ^ ^ |w|  *");
        $display(" *****************************   \\m___m__|_|  *");
        $display(" **********************************************");   
    end
    else begin
        $display("\n");
        $display(" ****************************               ");
        $display(" **                        **       |\__||  ");
        $display(" **  OOPS!!                **      / X,X  | ");
        $display(" **                        **    /_____   | ");
        $display(" **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display(" **                        **  |^ ^ ^ ^ |w| ");
        $display(" ****************************   \\m___m__|_|");
    end  
    $finish;
end

endmodule