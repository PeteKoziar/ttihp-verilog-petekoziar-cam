`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Pete Koziar
//
// Module Name: CamCell
// Project Name:
// Target Devices:
// Tool Versions:
// Description: One cell of a Content Addressable Memory, arranged in rows and
//              columns.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module CamCell
    #(parameter WIDTH = 8)
    (
    input  wire [WIDTH-1:0] pattern,
    input  wire [WIDTH-1:0] notPattern,
    input  wire nReset,
    input  wire last_row_found,
    input  wire last_column_found,
    input  wire last_free,
    input  wire store,
    input  wire nStore,
    output wire row_found,
    output wire column_found,
    output wire free
    );

    wire [WIDTH-1:0] matchBits;
    wire             match;

    wire a;
    wire b;
    wire cf;    // Takes on last_free when store is high
    wire d;
    wire e;
    wire f;
    wire xcf;   // Takes on cf when nstore is high
    wire g;

    assign free = xcf;

    // The enable signal / clock:
    assign a = !( last_free & store);
    assign b = !(!last_free & store);

    // The first latch stage:
    assign cf = !(nReset & a & d);
    assign d  = !(cf & b);

    // The second stage latch:
    assign e = !(cf & nStore);
    assign f = !( d & nStore);
    assign xcf = !(nReset & e & g);
    assign g   = !(f & xcf);

    assign wr = store & xcf & !cf;

    assign match        = (matchbits == {WIDTH{1'b1}});
    assign row_found    = last_row_found    | match;
    assign column_found = last_column_found | match;

    generate
        for(bits = 0; bits < WIDTH; bits = bits + 1)
            CAMbit cbit (
                .d(pattern[bits]),
                .e(wr),
                .notD(notPattern[bits]),
                .nReset(nReset),
                .match(matchBits[bits])
            );
    endgenerate


endmodule