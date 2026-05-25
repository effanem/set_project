module gf64_mul (
    input  wire [63:0] a,
    input  wire [63:0] b,
    output reg  [127:0] product
);

    integer i;
    reg [127:0] temp_shift;

    always @(*) begin
        product = 128'b0;
        for (i = 0; i < 64; i = i + 1) begin
            if (b[i]) begin
                // shift a into 128-bit space by i positions
                temp_shift = ({64'b0, a} << i);
                product = product ^ temp_shift; // XOR for polynomial add
            end
        end
    end

endmodule
