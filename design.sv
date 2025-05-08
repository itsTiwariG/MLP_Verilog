module mlp(
    input wire clk,
    input wire rst,
    input wire train,
    input wire [15:0] x1,
    input wire [15:0] x2,
    input wire [15:0] y_target,
    output wire [15:0] y_out,
    output wire training_done
);

    parameter LEARNING_RATE = 16'h0080;
    parameter NUM_TRAINING_ITERATIONS = 1000;
    parameter FIXED_ONE = 16'h0100;

    reg [15:0] w1_1;
    reg [15:0] w1_2;
    reg [15:0] w2_1;
    reg [15:0] w2_2;
    reg [15:0] w3_1;
    reg [15:0] w3_2;

    reg [15:0] h1_in;
    reg [15:0] h2_in;
    reg [15:0] h1;
    reg [15:0] h2;
    reg [15:0] y_in;
    reg [15:0] y;
    
    reg [15:0] delta_output;
    reg [15:0] delta_hidden1;
    reg [15:0] delta_hidden2;
    
    reg [15:0] sigmoid_derivative_output;
    reg [15:0] sigmoid_derivative_h1;
    reg [15:0] sigmoid_derivative_h2;
    
    reg [31:0] iteration_counter;
    reg done;

    assign y_out = y;
    assign training_done = done;

    always @(*) begin
        h1_in = fixed_point_mult(w1_1, x1) + fixed_point_mult(w2_1, x2);
        h2_in = fixed_point_mult(w1_2, x1) + fixed_point_mult(w2_2, x2);
        
        h1 = sigmoid(h1_in);
        h2 = sigmoid(h2_in);
        
        y_in = fixed_point_mult(w3_1, h1) + fixed_point_mult(w3_2, h2);
        y = sigmoid(y_in);
        
        sigmoid_derivative_output = sigmoid_derivative(y);
        sigmoid_derivative_h1 = sigmoid_derivative(h1);
        sigmoid_derivative_h2 = sigmoid_derivative(h2);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            w1_1 <= 16'h0040;
            w1_2 <= 16'h0060;
            w2_1 <= 16'h0050;
            w2_2 <= 16'h0070;
            w3_1 <= 16'h0048;
            w3_2 <= 16'h0058;
            
            iteration_counter <= 0;
            done <= 0;
        end
        else if (train && !done) begin
            delta_output = fixed_point_mult((y - y_target), sigmoid_derivative_output);
            
            delta_hidden1 = fixed_point_mult(fixed_point_mult(delta_output, w3_1), sigmoid_derivative_h1);
            delta_hidden2 = fixed_point_mult(fixed_point_mult(delta_output, w3_2), sigmoid_derivative_h2);
            
            w3_1 <= w3_1 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_output), h1);
            w3_2 <= w3_2 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_output), h2);
            
            w1_1 <= w1_1 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_hidden1), x1);
            w2_1 <= w2_1 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_hidden1), x2);
            w1_2 <= w1_2 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_hidden2), x1);
            w2_2 <= w2_2 - fixed_point_mult(fixed_point_mult(LEARNING_RATE, delta_hidden2), x2);
            
            if (iteration_counter == NUM_TRAINING_ITERATIONS - 1) begin
                done <= 1;
            end else begin
                iteration_counter <= iteration_counter + 1;
            end
        end
    end

    function [15:0] fixed_point_mult;
        input [15:0] a;
        input [15:0] b;
        reg [31:0] temp;
        begin
            temp = a * b;
            fixed_point_mult = temp[23:8];
        end
    endfunction

    function [15:0] sigmoid;
        input [15:0] x;
        reg [15:0] result;
        reg [7:0] index;
        reg [15:0] sigmoid_lut [0:255];
        integer i;
        begin
            for (i = 0; i < 256; i = i + 1) begin
                case (i)
                    0:  sigmoid_lut[i] = 16'h0003;
                    16: sigmoid_lut[i] = 16'h000A;
                    32: sigmoid_lut[i] = 16'h001B;
                    48: sigmoid_lut[i] = 16'h0046;
                    64: sigmoid_lut[i] = 16'h00B8;
                    80: sigmoid_lut[i] = 16'h01C6;
                    96: sigmoid_lut[i] = 16'h0432;
                    112: sigmoid_lut[i] = 16'h0800;
                    128: sigmoid_lut[i] = 16'h0080;
                    144: sigmoid_lut[i] = 16'h00C0;
                    160: sigmoid_lut[i] = 16'h00DD;
                    176: sigmoid_lut[i] = 16'h00E9;
                    192: sigmoid_lut[i] = 16'h00F3;
                    208: sigmoid_lut[i] = 16'h00F8;
                    224: sigmoid_lut[i] = 16'h00FB;
                    240: sigmoid_lut[i] = 16'h00FD;
                    255: sigmoid_lut[i] = 16'h00FE;
                    default: begin
                        if (i < 128)
                            sigmoid_lut[i] = 16'h0080 - (((128-i) * 16'h0080) >> 7);
                        else
                            sigmoid_lut[i] = 16'h0080 + (((i-128) * 16'h0080) >> 7);
                    end
                endcase
            end
            
            if (x[15]) begin
                if (x < 16'hF800)
                    index = 0;
                else
                    index = 128 + ((x[14:8] + 8'h10) & 8'h7F);
            end
            else begin
                if (x > 16'h0800)
                    index = 255;
                else
                    index = 128 + (x[14:8] & 8'h7F);
            end
            
            result = sigmoid_lut[index];
            sigmoid = result;
        end
    endfunction

    function [15:0] sigmoid_derivative;
        input [15:0] sigmoid_value;
        begin
            sigmoid_derivative = fixed_point_mult(sigmoid_value, (FIXED_ONE - sigmoid_value));
        end
    endfunction

endmodule