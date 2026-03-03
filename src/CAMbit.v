//`timescale 1ns / 1ps

module CAMbit (
    input wire d, 
    input wire e, 
    input wire notD,
    input wire nReset,
    output wire match
);

    wire a, b, matchD, matchNotD, q, notQ;

    // The s/r latch:
    assign a    = !(   d & e);
    assign b    = !(notD & e);
    assign q    = !(a & notQ);
    assign notQ = !(b & q & nReset);

    // The comparison:
    assign matchD    = !(d & q);
    assign matchNotD = !(notD & notQ);
    assign match     = !(matchD | matchNotD);

endmodule
