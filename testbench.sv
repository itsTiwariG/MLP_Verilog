`timescale 1ns / 1ps

module mlp_tb;

    reg clk;
    reg rst;
    reg train;
    reg [15:0] x1;
    reg [15:0] x2;
    reg [15:0] y_target;
    
    wire [15:0] y_out;
    wire training_done;
    
    reg [15:0] training_data [0:9][0:2];
    
    reg [15:0] test_x1;
    reg [15:0] test_x2;
    reg [15:0] expected_y;
    
    mlp uut (
        .clk(clk),
        .rst(rst),
        .train(train),
        .x1(x1),
        .x2(x2),
        .y_target(y_target),
        .y_out(y_out),
        .training_done(training_done)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    integer i;
    
    initial begin
        training_data[0][0] = 16'h0000;
        training_data[0][1] = 16'h0000;
        training_data[0][2] = 16'h0000;
        
        training_data[1][0] = 16'h0000;
        training_data[1][1] = 16'h0100;
        training_data[1][2] = 16'h0100;
        
        training_data[2][0] = 16'h0100;
        training_data[2][1] = 16'h0000;
        training_data[2][2] = 16'h0100;
        
        training_data[3][0] = 16'h0100;
        training_data[3][1] = 16'h0100;
        training_data[3][2] = 16'h0000;
        
        training_data[4][0] = 16'h0020;
        training_data[4][1] = 16'h0020;
        training_data[4][2] = 16'h0000;
        
        training_data[5][0] = 16'h0020;
        training_data[5][1] = 16'h00E0;
        training_data[5][2] = 16'h0100;
        
        training_data[6][0] = 16'h00E0;
        training_data[6][1] = 16'h0020;
        training_data[6][2] = 16'h0100;
        
        training_data[7][0] = 16'h00E0;
        training_data[7][1] = 16'h00E0;
        training_data[7][2] = 16'h0000;
        
        training_data[8][0] = 16'h0050;
        training_data[8][1] = 16'h0050;
        training_data[8][2] = 16'h0000;
        
        training_data[9][0] = 16'h00C0;
        training_data[9][1] = 16'h00C0;
        training_data[9][2] = 16'h0000;
        
        test_x1 = 16'h0080;
        test_x2 = 16'h0080;
        expected_y = 16'h0000;
        
        rst = 1;
        train = 0;
        #10;
        rst = 0;
        #10;
        
        train = 1;
        
        for (i = 0; i < 300; i = i + 1) begin
            x1 = training_data[i % 10][0];
            x2 = training_data[i % 10][1];
            y_target = training_data[i % 10][2];
            #10;
        end
        
        train = 0;
        #10;
        
        x1 = test_x1;
        x2 = test_x2;
        #10;
        
        $display("Test Result:");
        $display("Inputs: x1 = %f, x2 = %f", real'(test_x1) / 256.0, real'(test_x2) / 256.0);
        $display("Expected output: %f", real'(expected_y) / 256.0);
        $display("Actual output: %f", real'(y_out) / 256.0);
        
        if (((y_out > 16'h0080) && (expected_y > 16'h0080)) || 
            ((y_out <= 16'h0080) && (expected_y <= 16'h0080))) begin
            $display("Test PASSED!");
        end
        
        $display("Final weights:");
        $display("w1_1 = %f", real'(uut.w1_1) / 256.0);
        $display("w1_2 = %f", real'(uut.w1_2) / 256.0);
        $display("w2_1 = %f", real'(uut.w2_1) / 256.0);
        $display("w2_2 = %f", real'(uut.w2_2) / 256.0);
        $display("w3_1 = %f", real'(uut.w3_1) / 256.0);
        $display("w3_2 = %f", real'(uut.w3_2) / 256.0);
        
        #100;
        $finish;
    end

endmodule