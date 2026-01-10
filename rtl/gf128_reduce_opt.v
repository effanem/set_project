// Optimized AES-GCM reduction
// Polynomial: x^128 + x^7 + x^2 + x + 1

module gf128_reduce_opt (
    input  wire [255:0] in,
    output wire [127:0] out
);

    wire [127:0] low;
    wire [127:0] high;

    assign low  = in[127:0];
    assign high = in[255:128];

    // Folding high part using AES-GCM polynomial
    assign out =
          low
        ^ high
        ^ (high << 1)
        ^ (high << 2)
        ^ (high << 7);

endmodule

/* just keeping non-optimized version here
which i used to understand the code initially.

The following code is not hardware optimized
Therfore, rejected and went for the above one

module gf128_reduce (
    input  wire [255:0] in,
    output reg  [127:0] out
);

    integer i;
    reg [127:0] low;
    reg [127:0] high;

    always @(*) begin
        // Splitting input
        low  = in[127:0];
        high = in[255:128];

        // Starting with lower part
        out = low;

        // Folding high bits using reduction polynomial
        for (i = 0; i < 128; i = i + 1) begin
            if (high[i]) begin
                out[i]     = out[i]     ^ 1'b1;        // x^i
                out[i+1]   = out[i+1]   ^ 1'b1;        // x^(i+1)
                out[i+2]   = out[i+2]   ^ 1'b1;        // x^(i+2)
                out[i+7]   = out[i+7]   ^ 1'b1;        // x^(i+7)
            end
        end
    end

endmodule

*/

