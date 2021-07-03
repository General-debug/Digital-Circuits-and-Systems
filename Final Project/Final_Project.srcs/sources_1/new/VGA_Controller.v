`timescale 1ns / 1ps

module Vga_Controller(	
				clk, rst_n,		
                display, map,
                Twinkle, Xcoord, Ycoord, Twinkle_pulse,                
                PS2_CLK, PS2_DATA, 
                Xgrid, Ygrid, Left, Middle, Cursor_valid, Right,
				hsync, vsync, vga_r, vga_g, vga_b	// 传给VGA的信号
			);

    input clk;	    // 100MHz
    input rst_n;	//reset-低位有效
    input [3:0] display; //切换显示界面
    input Twinkle;
    input [3:0] Xcoord, Ycoord;
    input Twinkle_pulse;
    input [16*16-1:0] map; //要显示的地图，将被作为输入
        
    output hsync;	      //行同步信号
    output vsync;	      //列同步信号
    output[3:0] vga_r;    //vga红色输出
    output[3:0] vga_g;     //vga绿色输出
    output[3:0] vga_b;      //vga蓝色输出

    inout PS2_CLK;
    inout PS2_DATA;

    wire[8:0] chosen;
    assign chosen = (Xcoord<<4) + Ycoord;


    reg[9:0] x_cnt;		//行计数器
    reg[9:0] y_cnt;		//列计数器
    reg clk_vga=0;    //vga时钟=25MHz
    reg clk_cnt=0;     //时钟计数


/*****************************************产生vga时钟-clk**********************************************/
    always @(posedge clk or negedge rst_n)begin //clock for vga
        if(!rst_n)
            clk_vga <= 1'b0;
	    else if(clk_cnt==1)begin
	       clk_vga <= ~clk_vga;
	       clk_cnt<=0; 
        end
        else
            clk_cnt <= clk_cnt+1;
     end


    reg valid_yr;	//行显示有效信号
    always @ (posedge clk_vga or negedge rst_n)begin //480行
        if(!rst_n) valid_yr <= 1'b0;
        else if(y_cnt == 10'd32) valid_yr <= 1'b1;
        else if(y_cnt == 10'd511) valid_yr <= 1'b0;    
    end

    wire valid_y = valid_yr;

    reg valid_r;    
    always @ (posedge clk_vga or negedge rst_n)begin //640列
        if(!rst_n) valid_r <= 1'b0;
        else if((x_cnt == 10'd141) && valid_y) valid_r <= 1'b1;
        else if((x_cnt == 10'd781) && valid_y) valid_r <= 1'b0;
    end
    wire valid = valid_r;    //有效信号


/*****************************************行同步、场同步*************************************/
    always @ (posedge clk_vga or negedge rst_n)begin
        if(!rst_n) x_cnt <= 10'd0;
        else if(x_cnt == 10'd799) x_cnt <= 10'd0;
        else x_cnt <= x_cnt+1'b1;
    end

    always @ (posedge clk_vga or negedge rst_n)begin
        if(!rst_n) y_cnt <= 10'd0;
        else if(y_cnt == 10'd524) y_cnt <= 10'd0;
        else if(x_cnt == 10'd799) y_cnt <= y_cnt+1'b1;
    end

	//VGA场同步、行同步信号
    reg hsync_r,vsync_r;	

    always @ (posedge clk_vga or negedge rst_n)begin
        if(!rst_n) hsync_r <= 1'b1;								
        else if(x_cnt == 10'd0) hsync_r <= 1'b0;	//hsync
        else if(x_cnt == 10'd96) hsync_r <= 1'b1;
    end

    always @ (posedge clk_vga or negedge rst_n)begin
        if(!rst_n) vsync_r <= 1'b1;							
        else if(y_cnt == 10'd0) vsync_r <= 1'b0;	//vsync
        else if(y_cnt == 10'd2) vsync_r <= 1'b1;
    end

    assign hsync = hsync_r;
    assign vsync = vsync_r;


/****************************************画布**********************************************/
    //640*480
    wire[9:0] x_dis;		//ֵrows:valid 0-639
    wire[9:0] y_dis;		//ֵcolumns:valid 0-479

    //减去消隐区，换算成坐标
    assign x_dis = x_cnt - 10'd142;
	assign y_dis = y_cnt - 10'd33;
    //定义一些需要的变量
    reg[11:0] vga_rgb;


/***************************************基本图标****************************************************/
//****************左上角生命游戏标识****************/
wire pic_valid;
localparam pic_left_grid = 0 + 10,
            pic_right_grid = 0 + 10 +100 + 1,
            pic_top_grid = 0 + 20,
            pic_bottom_grid = 0 + 20 + 40 + 1; 

wire[16:0] pic_addra;
wire[11:0] pic_douta;
reg [16:0] pic_cnt_addr;
wire pic_end_cnt_addr;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n) begin
        pic_cnt_addr <= 0;
    end
    else if(pic_valid) begin
        if(pic_end_cnt_addr)
            pic_cnt_addr <= 0;
        else 
            pic_cnt_addr <= pic_cnt_addr + 1;
    end
end
assign pic_valid = x_dis > pic_left_grid & x_dis < pic_right_grid & y_dis > pic_top_grid & y_dis < pic_bottom_grid; 
assign pic_end_cnt_addr = pic_valid & pic_cnt_addr== 100*40 - 1;
assign pic_addra = pic_cnt_addr;

// assign pic_douta = 12'b0000_0000_1111;
//读取ROM中的数据
blk_mem_gen_3 bram_pic(
    .clka(clk_vga),
    .ena(pic_valid),
    .addra(pic_addra),
    .douta(pic_douta)
);

//****************右下角作者标识****************/
wire con_valid;
localparam con_left_grid =  480,
            con_right_grid = 480 + 128 + 1,
            con_top_grid = 376,
            con_bottom_grid = 376 + 90 + 1; 

wire[16:0] con_addra;
wire[11:0] con_douta;
reg [16:0] con_cnt_addr;
wire con_end_cnt_addr;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n) begin
        con_cnt_addr <= 0;
    end
    else if(con_valid) begin
        if(con_end_cnt_addr)
            con_cnt_addr <= 0;
        else 
            con_cnt_addr <= con_cnt_addr + 1;
    end
end
assign con_valid = x_dis > con_left_grid & x_dis < con_right_grid & y_dis > con_top_grid & y_dis < con_bottom_grid; 
assign con_end_cnt_addr = con_valid & con_cnt_addr== 128*90 - 1;
assign con_addra = con_cnt_addr;

// assign pic_douta = 12'b0000_0000_1111;
//读取ROM中的数据
blk_mem_gen_7 bram_con(
    .clka(clk_vga),
    .ena(con_valid),
    .addra(con_addra),
    .douta(con_douta)
);

/***************************************开始/模式界面************************************************/
wire start_page_valid;
wire normal_page_valid;
wire continue_page_valid;
reg [16:0] cnt_addr;
wire end_cnt_addr;
wire add_cnt_addr;
wire[16:0] addra;
wire[11:0] douta0;
wire[11:0] douta1;
wire[11:0] douta2;

//图片大小
localparam x_l = 100;
localparam y_l = 30;
localparam start_left_grid =  320 - (x_l>>1);
localparam start_right_grid = 320 + (x_l>>1) + 1; 
localparam start_top_grid = 240 - (y_l>>1);
localparam start_bottom_grid = 240 + (y_l>>1) + 1;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n | display == 1) begin
        cnt_addr <= 0;
    end
    else if(add_cnt_addr) begin
        if(end_cnt_addr)
            cnt_addr <= 0;
        else 
            cnt_addr <= cnt_addr + 1;
    end
end

assign end_cnt_addr = add_cnt_addr & cnt_addr== x_l*y_l - 1;
assign addra = cnt_addr;
assign add_cnt_addr = start_page_valid + normal_page_valid + continue_page_valid;


assign start_page_valid = (display==2) & x_dis > start_left_grid & x_dis < start_right_grid & y_dis > start_top_grid & y_dis < start_bottom_grid;
assign normal_page_valid = (display==3) & x_dis > start_left_grid & x_dis < start_right_grid & y_dis > start_top_grid & y_dis < start_bottom_grid;
assign continue_page_valid = (display==4) & x_dis > start_left_grid & x_dis < start_right_grid & y_dis > start_top_grid & y_dis < start_bottom_grid;

// assign douta0 = 12'b1111_1111_1111;
// assign douta1 = 12'b0000_1111_1111;
// assign douta2 = 12'b1111_0000_1111;
//读取ROM中的数据
blk_mem_gen_0 bram0(
    .clka(clk_vga),
    .ena(start_page_valid),
    .addra(addra),
    .douta(douta0)
);

blk_mem_gen_1 bram1(
    .clka(clk_vga),
    .ena(normal_page_valid),
    .addra(addra),
    .douta(douta1)
);

blk_mem_gen_2 bram2(
    .clka(clk_vga),
    .ena(continue_page_valid),
    .addra(addra),
    .douta(douta2)
);

/********************************************游戏界面************************************************************/
    
    wire[3:0] x;
    wire[3:0] y;
    wire[9:0] grid_num;
    wire grid_valid;
    wire border_valid;//要显示边界线的区域


    localparam left_grid = 320 - 128;//格子左边界
    localparam right_grid = 320 + 128;//格子右边界
    localparam pixel_grid = 16;//单个格子长度
    localparam top_grid = 240 - 128;//格子上边界
    localparam bottom_grid = 240 + 128;//格子下边界

//有效格子界面
assign grid_valid = x_dis > left_grid & x_dis < right_grid & y_dis > top_grid & y_dis < bottom_grid; 
//将像素区间和map[16*16-1]对应
assign x = grid_valid ? (x_dis-left_grid)>>4 : 0;
assign y = grid_valid ? (y_dis-top_grid)>>4 : 0;
assign grid_num = x + (y<<4);

wire[9:0] xx_dis;
wire[9:0] yy_dis;
localparam down_res = 1;
localparam dleft = left_grid>>down_res;
localparam dright = right_grid>>down_res;
localparam dtop = top_grid>>down_res;
localparam dbottom = bottom_grid>>down_res;
localparam dpixel = pixel_grid>>down_res;

assign xx_dis = x_dis>>down_res;//降低分辨率
assign yy_dis = y_dis>>down_res;

//游戏界面的格子边框
assign border_valid = ((xx_dis >= dleft & xx_dis <= dright & (
                        yy_dis == dtop | yy_dis == dbottom |
                        yy_dis == dtop + dpixel |
                        yy_dis == dtop + dpixel*2 |
                        yy_dis == dtop + dpixel*3 |
                        yy_dis == dtop + dpixel*4 |
                        yy_dis == dtop + dpixel*5 |
                        yy_dis == dtop + dpixel*6 |
                        yy_dis == dtop + dpixel*7 |
                        yy_dis == dtop + dpixel*8 |
                        yy_dis == dtop + dpixel*9 |
                        yy_dis == dtop + dpixel*10 |
                        yy_dis == dtop + dpixel*11 |
                        yy_dis == dtop + dpixel*12 |
                        yy_dis == dtop + dpixel*13 |
                        yy_dis == dtop + dpixel*14 |
                        yy_dis == dtop + dpixel*15 
                        )) |
                        (yy_dis >= dtop & yy_dis <= dbottom & (
                        xx_dis == dleft | xx_dis == dright |
                        xx_dis == dleft + dpixel |
                        xx_dis == dleft + dpixel*2 |
                        xx_dis == dleft + dpixel*3 |
                        xx_dis == dleft + dpixel*4 |
                        xx_dis == dleft + dpixel*5 |
                        xx_dis == dleft + dpixel*6 |
                        xx_dis == dleft + dpixel*7 |
                        xx_dis == dleft + dpixel*8 |
                        xx_dis == dleft + dpixel*9 |
                        xx_dis == dleft + dpixel*10 |
                        xx_dis == dleft + dpixel*11 |
                        xx_dis == dleft + dpixel*12 |
                        xx_dis == dleft + dpixel*13 |
                        xx_dis == dleft + dpixel*14 |
                        xx_dis == dleft + dpixel*15 
                        )));

//***************tip显示**********************/
wire tip0_valid;
localparam tip0_left_grid = 0 + 40,
            tip0_right_grid = 0 + 40 + 100 + 1,
            tip0_top_grid = 0 + 240 - 128 + 4 ,
            tip0_bottom_grid = 0 + 240 - 128 + 4 + 15 + 1; 

wire[16:0] tip0_addra;
wire[11:0] tip0_douta;
reg [16:0] tip0_cnt_addr;
wire tip0_end_cnt_addr;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n) begin
        tip0_cnt_addr <= 0;
    end
    else if(tip0_valid) begin
        if(tip0_end_cnt_addr)
            tip0_cnt_addr <= 0;
        else 
            tip0_cnt_addr <= tip0_cnt_addr + 1;
    end
end

assign tip0_valid = x_dis > tip0_left_grid & x_dis < tip0_right_grid & y_dis > tip0_top_grid & y_dis < tip0_bottom_grid; 
assign tip0_end_cnt_addr = tip0_valid & tip0_cnt_addr== 100*15 - 1;
assign tip0_addra = tip0_cnt_addr;

// assign pic_douta = 12'b0000_0000_1111;
//读取ROM中的数据
blk_mem_gen_4 bram_tip0(
    .clka(clk_vga),
    .ena(tip0_valid),
    .addra(tip0_addra),
    .douta(tip0_douta)
);


//***************tip1显示**********************/
wire tip1_valid;
localparam tip1_left_grid = 0 + 40,
            tip1_right_grid = 0 + 40 + 100 + 1,
            tip1_top_grid = 0 + 240 - 128 + 4 + 30,
            tip1_bottom_grid = 0 + 240 - 128 + 4 + 30 + 15 + 1; 

wire[16:0] tip1_addra;
wire[11:0] tip1_douta;
reg [16:0] tip1_cnt_addr;
wire tip1_end_cnt_addr;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n) begin
        tip1_cnt_addr <= 0;
    end
    else if(tip1_valid) begin
        if(tip1_end_cnt_addr)
            tip1_cnt_addr <= 0;
        else 
            tip1_cnt_addr <= tip1_cnt_addr + 1;
    end
end

assign tip1_valid = x_dis > tip1_left_grid & x_dis < tip1_right_grid & y_dis > tip1_top_grid & y_dis < tip1_bottom_grid; 
assign tip1_end_cnt_addr = tip1_valid & tip1_cnt_addr== 100*15 - 1;
assign tip1_addra = tip1_cnt_addr;

// assign pic_douta = 12'b0000_0000_1111;
//读取ROM中的数据
blk_mem_gen_5 bram_tip1(
    .clka(clk_vga),
    .ena(tip1_valid),
    .addra(tip1_addra),
    .douta(tip1_douta)
);

//***************tip2显示**********************/
wire tip2_valid;
localparam tip2_left_grid = 0 + 40,
            tip2_right_grid = 0 + 40 + 90 + 1,
            tip2_top_grid = 0 + 240 - 128 + 4 + 30 + 30,
            tip2_bottom_grid = 0 + 240 - 128 + 4 + 30 + 30 + 27 + 1; 

wire[16:0] tip2_addra;
wire[11:0] tip2_douta;
reg [16:0] tip2_cnt_addr;
wire tip2_end_cnt_addr;

//BRAM读取地址计数器
always @(posedge clk_vga or negedge rst_n) begin
    if(!rst_n) begin
        tip2_cnt_addr <= 0;
    end
    else if(tip2_valid) begin
        if(tip2_end_cnt_addr)
            tip2_cnt_addr <= 0;
        else 
            tip2_cnt_addr <= tip2_cnt_addr + 1;
    end
end

assign tip2_valid = x_dis > tip2_left_grid & x_dis < tip2_right_grid & y_dis > tip2_top_grid & y_dis < tip2_bottom_grid; 
assign tip2_end_cnt_addr = tip2_valid & tip2_cnt_addr== 90*27 - 1;
assign tip2_addra = tip2_cnt_addr;

// assign pic_douta = 12'b0000_0000_1111;
//读取ROM中的数据
blk_mem_gen_6 bram_tip2(
    .clka(clk_vga),
    .ena(tip2_valid),
    .addra(tip2_addra),
    .douta(tip2_douta)
);

/****************************************引入鼠标***************************************************/
wire [11:0] xpos;
wire [11:0] ypos;
wire [11:0] vga_cursor;
wire enable_mouse_display_out;
output wire Left, Middle, Right;
MouseCtl MouseCtl_inst(.clk(clk),.rst(!rst_n),
                        .ps2_clk(PS2_CLK),.ps2_data(PS2_DATA),
                        .setx(320),.sety(240),.setmax_x(640),.setmax_y(480),
                        .xpos(xpos),.ypos(ypos),.left(Left),.middle(Middle),.right(Right));

MouseDisplay MouseDisplay(.pixel_clk(clk_vga),
                        .xpos(xpos),.ypos(ypos),
                        .hcount(x_dis),.vcount(y_dis),
                        .red_in(vga_r),.green_in(vga_g),.blue_in(vga_b),
                        .enable_mouse_display_out(enable_mouse_display_out),
                        .red_out(vga_cursor[11:8]),.green_out(vga_cursor[7:4]),.blue_out(vga_cursor[3:0]));

//将鼠标信息传给控制器
output wire[3:0] Xgrid, Ygrid;
output wire Cursor_valid;
assign Cursor_valid = xpos > left_grid & xpos < right_grid & ypos > top_grid & ypos < bottom_grid; 
assign Ygrid = (xpos-left_grid) >> 4;
assign Xgrid = (ypos-top_grid) >> 4;


/************************************************综合显示**********************************************************/
always @ (posedge clk_vga) begin//输出每一行的信号
    if(!valid) vga_rgb = 12'b0000_0000_0000;//黑色
    else begin
        if(pic_valid)
            vga_rgb = pic_douta;
        else if(con_valid)
            vga_rgb = con_douta;
        else begin
            case (display)
                2: vga_rgb = start_page_valid? douta0:0;
                3: vga_rgb = normal_page_valid? douta1:0;
                4: vga_rgb = continue_page_valid? douta2:0;
                default: begin//显示“游戏界面”
                    if(border_valid) vga_rgb = 12'b1111_1111_1111;//边框显示白色
                    else if(tip0_valid) vga_rgb = tip0_douta;
                    else if(tip1_valid) vga_rgb = tip1_douta;
                    else if(tip2_valid) vga_rgb = tip2_douta;
                    else if(grid_valid) begin
                        if(grid_num == chosen) begin
                            if(Twinkle)
                                vga_rgb <= Twinkle_pulse ? 12'b1111_1111_1111 : 12'b0000_0000_0000;
                            else
                                vga_rgb <= map[grid_num] ? 12'b1111_0111_1001 : 12'b0000_0000_0000;
                        end
                        else 
                            vga_rgb <= map[grid_num] ? 12'b1111_0111_1001 : 12'b0000_0000_0000;//有生命显示偏红色,无生命显示黑色
                    end
                    else vga_rgb <= 12'b0000_0000_0000; //其他界面显示黑色
                end
            endcase
        end
    end
end  

    assign vga_r = enable_mouse_display_out ? vga_cursor[11:8] : vga_rgb[11:8];
    assign vga_g = enable_mouse_display_out ? vga_cursor[7:4] : vga_rgb[7:4];
    assign vga_b = enable_mouse_display_out ? vga_cursor[3:0] : vga_rgb[3:0];

endmodule


