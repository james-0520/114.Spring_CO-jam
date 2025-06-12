// use ChatGPT

module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);

// TO DO
input memread;
input [31:0] instr_i;
input [4:0] idex_regt;
input branch;
output reg pcwrite;
output reg ifid_write;
output reg ifid_flush;
output reg idex_flush;
output reg exmem_flush;

wire [4:0] rs, rt;

    assign rs = instr_i[25:21];
    assign rt = instr_i[20:16];

    always @(*) begin
        // 預設正常運作
        pcwrite     = 1;
        ifid_write  = 1;
        ifid_flush  = 0;
        idex_flush  = 0;
        exmem_flush = 0;

        // Load-use 資料冒險偵測
        if (memread && ((idex_regt == rs) || (idex_regt == rt))) begin
            pcwrite     = 0;
            ifid_write  = 0;
            idex_flush  = 1;
        end

        // Branch 錯誤預測處理
        if (branch) begin
            ifid_flush  = 1;
            exmem_flush = 1;
        end
    end


endmodule