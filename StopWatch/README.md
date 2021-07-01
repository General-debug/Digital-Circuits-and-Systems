# 秒表 设计报告

说明：Basys3，vivado，Verilog HDL。

## 一、系统描述

### 1. 功能介绍

​	实现一个单键按秒表，即其操作模式可以通过单个按键进行控制。按一下按键BTN，秒表开始计时，计时过程显示在4个数码管上；再次按一下按键 BTN，秒表暂停计时，并显示当前计时时间；再次按一下按键BTN，秒表清零，并回到初始等待计时的状态。该秒表的计时范围为0-59.99秒。发生溢出时，将点亮一个报警LED。

​	要求：计数精度1ms，显示精度10ms。

### 2. 输入输出

​	输入：系统时钟`clk`，按键`btnc`，重置`rst`；

​	输出：时间显示：数码管片选信号`led_sel_n[3:0]`，数码管段选信号`led_segs_n`，数码管小数点显示`led_dp`，溢出提醒`over_flow`。

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628100343924.png" alt="image-20210628100343924" style="zoom:30%;" />

### 3. 系统框图

​	该系统主要分为4四个模块，即计时模块、使能发生模块、数码管扫描显示模块、系统控制模块，具体如下图。

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628095628131.png" style="zoom:80%;" />

### 4. 实验器材

​	Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)

​	使用vivado 2020.2进行仿真、综合、实现和下载

​	使用vscode作为编辑器，未使用vivado自带的编辑器，可能在vivado直接打开的情况下出现中文乱码。

## 二、分模块设计

### 1. 使能发生模块

#### 1.1 描述

​	使能发生模块用分频的方式实现，如下图。其中参数N为分频的倍数，可通过调用模块修改参数实现不同的分频。

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628100234702.png" alt="image-20210628100234702" style="zoom:50%;" />

#### 1.2 `verilog`代码

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 11:41:19
// Design Name: StopWatch
// Module Name: entime
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 使能发生模块,通过修改参数N修改分频时间。
//
//////////////////////////////////////////////////////////////////////////////////

module entime(
    input clk,
    output reg pulse_output
    );
    
    reg[28:0] cnt;
    parameter N = 10;//分频的参数，可在调用模块时修改
    parameter pulse = 1;//脉冲信号的宽度
    
    always @(posedge clk) begin 
        if(cnt < N-1)
            cnt <= cnt + 1;
        else cnt <= 0;
    end
    
    always @(posedge clk) begin//
        if(cnt < pulse)
            pulse_output <= 1;
        else pulse_output <= 0;
    end
    
endmodule
```

### 2. 系统控制模块

#### 2.1 描述

​	包含了按键消抖部分和状态机两部分.

##### 2.1.1按键消抖设计

![image-20210628103234187](C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628103234187.png)

​	当按键按下时，由于按键本身的机械特性，以及人手在按下过程中可能会有抖动，所产生的高电平信号一般不会是干净的信号，其波形如图3-2所示的`bin_in`信号所示，但该信号的中间高电平会保持一段时间，长度在10ms-20ms之间，因此，我们可以利用这一点来产生一个干净的按键输出，如上图 `btn_out`信号所示，具体原理就是每10ms采样一次，你如果连续两次均检测到高电平，则表明有一次按键发生。 要注意的是，上面的波形图中虽然没有画出时钟信号，但`pulse10ms`信号和`btn_out`的高电平宽度均为一个时钟宽度10ns，当`btn_out`信号输入到同步状态机时，由于状态机的时钟是 100MHz的，所以每次按键只会发生一次状态转换，而不是多次状态转换，体现出按键消抖的效 果。

​	在下面的代码中，我每10ms采一次样，当上次采样为0，这次采样为1，则认为按了一次按键且按键动作完成，输出10ns的`btn_out`脉冲。

##### 2.1.2状态机设计

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628105017259.png" alt="image-20210628105017259" style="zoom:30%;" />

#### 2.2 `verilog`代码

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 00:41:19
// Design Name: StopWatch
// Module Name: controller
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 状态机程序，实现秒表不同状态的转换。预先对输入的按键进行消抖处理。
// 
//////////////////////////////////////////////////////////////////////////////////

module controller(
    input btnc,
    input clk,
    input rst,
    input pulse_10ms,
    output reg work,
    output reg clear
    );
    
    reg [1:0] PresentS, NextS;
    parameter[1:0] IDLE = 2'b00,WORKING = 2'b01, STOPPING = 2'b11;

    reg PreviousBtnc_0;
    reg PreviousBtnc_1;
    wire btn_out;
    
    //初始设置，方便仿真
    initial begin
        PresentS = IDLE;
        NextS = IDLE;
    end
    
    initial begin
        PreviousBtnc_0 = 1'b0;
        PreviousBtnc_1 = 1'b0;
    end
    
    //按键消抖
    always @(posedge clk) begin
        if(pulse_10ms)
            PreviousBtnc_1 <= btnc;
        else
            PreviousBtnc_1 <= PreviousBtnc_1;
        
        PreviousBtnc_0 <= PreviousBtnc_1;
    end
    
    assign btn_out = PreviousBtnc_0 & (~PreviousBtnc_1);
    
    //激励方程部分
    always @(btn_out, rst) begin
        if(rst) NextS = IDLE;
        else begin
            case(PresentS)
                IDLE: if(btn_out == 1) NextS = WORKING;else NextS = IDLE;
                WORKING: if(btn_out == 1) NextS = STOPPING; else NextS = WORKING;
                STOPPING: if(btn_out == 1) NextS = IDLE; else NextS = STOPPING;
                default: NextS = IDLE;
            endcase
        end
    end 
    
    //状态赋值
    always @(posedge clk) begin
        PresentS <= NextS;
    end
    
    //Moore机输出
    always @(PresentS) begin
        case(PresentS)
            IDLE: begin work = 0;clear = 1;end
            WORKING: begin work = 1;clear = 0;end
            STOPPING: begin work = 0;clear = 0; end
            default: begin work = 0;clear = 0; end
        endcase
    end
    
endmodule
```

### 3. 计时模块

#### 3.1 描述

​	显示两位小数的秒表计时，显示精度为10ms，用 bcd码计数，从高到低依次为`bcd_a, bcd_b, bcd_c, bcd_d`。

#### 3.2 `verilog`代码

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/20 16:41:25
// Design Name: StopWatch
// Module Name: counter
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 实现计时功能，将计数的bcd结果传给七段数码管，产生over_flow信号。
// 
//////////////////////////////////////////////////////////////////////////////////

module counter(
    input work,
    input clear,
    input pulse_1ms,//计数精度为1ms
    output reg[3:0] bcd_a,
    output reg[3:0] bcd_b,
    output reg[3:0] bcd_c,
    output reg[3:0] bcd_d,
    output reg over_flow
    );

    reg[16:0] cnt;//用于计数
    parameter TIME = 9;//TIME计数，结果得到10ms
    initial begin
        cnt = 0;
        bcd_a = 0;
        bcd_b = 0;
        bcd_c = 0;
        bcd_d = 0;
        over_flow = 0;
    end
    //计数
    always @(posedge pulse_1ms) begin
        if(clear) 
            cnt <= 0;
        else if(work)
            if(cnt < TIME)
                cnt <= cnt + 1;
            else cnt <= 0;
        else cnt <= cnt;
    end          
        
    always @(posedge pulse_1ms) begin
        if(clear) begin
            bcd_c <= 0;
            bcd_d <= 0;
        end
        else if(work & cnt == TIME) begin
            if(bcd_d < 9) begin
                bcd_d <= bcd_d + 1;
            end 
            else begin
                bcd_c <= bcd_c + 1;
                bcd_d <= 0;
                if(bcd_c == 9) begin
                    bcd_c <= 0;
                end
            end
       end
       else begin 
            bcd_d <= bcd_d;
            bcd_c <= bcd_c;
       end
    end

    always @(posedge pulse_1ms) begin
        if(clear) begin
            bcd_a <= 0;
            bcd_b <= 0;
            over_flow <= 0;
        end
        else if(work & bcd_c==9 & bcd_d == 9 & cnt == TIME) begin
            if(bcd_b < 9) begin
                bcd_b <= bcd_b + 1;
                over_flow <= 0;
            end
            else begin
                bcd_a <= bcd_a + 1;
                bcd_b <= 0;
                if(bcd_a == 5) begin
                    bcd_a <= 0;
                    over_flow <= 1;
                end  
            end
        end
        else begin
            bcd_a <= bcd_a;
            bcd_b <= bcd_b;
        end
    end
                 
endmodule
```

### 4. 扫描显示模块

#### 4.1描述

​	扫描显示模块，将计时模块生成的bcd码的计数编码成四位七段数码管的显示。

​	数码管的显示原理图如下：

<img src="C:\Users\dell\AppData\Roaming\Typora\typora-user-images\image-20210628105815352.png" style="zoom:70%;" />

​	在Basys3的开发板上共有4个共阳的七段数码管，这些数码管的各个显示段LED的阴极连接在一起，当需要在相应的位置显示某个数字时，其数码管的阴极端对应该数字相应笔画的控制信号，如显示“0”时，a,b,c,d,e,f,g 字段的控制端CA,CB,CC,CD,CE,CF=0, 而f段控制 信号 CG=1，小数点控制信号 DP=1，此时，如果相应的共阳极导通的话，则“0”显示在相应的位置上，如 U2=0，控制 AN0 导通，则“0”显示在最右边的数码管上。如果要在四个数码管上显示不同的数字，这需要在从W4，V4，U4和U2输出的扫描控制信号LEDSEL(0..3) 分时段为0，同时，把相应的数字控制信号输出到LEDSEG(0..7)=(CA,CB,CC,CD,CE,CF,CG,DP)上，由于人的眼睛具有视觉暂留效应，当这些数码管的扫描显示频率大于24Hz时，则在视觉上可以看到四个数码管同时显示的效果。

​	为分频方便，在本实验中使用200Hz的`ena`信号。

#### 4.2`verilog`代码

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 11:19:01
// Design Name: StopWatch
// Module Name: Vr7display
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 显示模块，驱动七段数码管
// 
//////////////////////////////////////////////////////////////////////////////////

module Vr7display(
    input [3:0] bcd_a,
    input [3:0] bcd_b,
    input [3:0] bcd_c,
    input [3:0] bcd_d,
    input [3:0] bcd_dp,
    input clk,
    input rst,
    input ena,
    output reg [3:0] led_sel_n,//片选信号
    output reg [6:0] led_segs_n,//段选信号
    output reg led_dp
    );
    
    reg [1:0] cnt;
    reg [3:0] num;
    
    initial begin
        cnt = 0;
        num = 0;
        led_sel_n = 4'b1111;
        led_segs_n=7'b0000001;
    end
    
    //片选模块
    always @(posedge clk) begin
        if(rst) begin
            led_sel_n <= 4'b1111;
            cnt <= 0;
            led_dp <= 1;
        end
        else if(ena) begin
            case(cnt)
                0: begin led_sel_n <= 4'b1110; num <= bcd_d; end
                1: begin led_sel_n <= 4'b1101; num <= bcd_c; end
                2: begin led_sel_n <= 4'b1011; num <= bcd_b; end
                3: begin led_sel_n <= 4'b0111; num <= bcd_a; end
                default led_sel_n <= 4'b1111;
            endcase
            led_dp <= bcd_dp[cnt];
            cnt <= cnt + 1;
        end
        else led_sel_n <= 4'b1111;
    end
        
    //段选模块
    always @(*) begin
        if(ena) begin
            case(num)
                4'd0:led_segs_n=7'b0000001;
                4'd1:led_segs_n=7'b1001111;
                4'd2:led_segs_n=7'b0010010;
                4'd3:led_segs_n=7'b0000110;
                4'd4:led_segs_n=7'b1001100;
                4'd5:led_segs_n=7'b0100100;
                4'd6:led_segs_n=7'b0100000;
                4'd7:led_segs_n=7'b0001111;
                4'd8:led_segs_n=7'b0000000;
                4'd9:led_segs_n=7'b0000100;
                default led_segs_n=7'b1111111;
           endcase
       end
       else led_segs_n = 7'b1111111;
    end
    
endmodule
```

## 三、仿真验证和实现

​	实验中先对各个模块的功能进行检查验证，依次用testbench和下板验证的方式进行验证。testbench仍保留在`Lab3\project_1\project_1.srcs\sim_1\new`文件夹中。下板验证的代码通过后已修改为现有模块，未保存。

​	各模块验证无误后用主体程序调用实现，主体程序如下：

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 8:05:07
// Design Name: StopWatch
// Module Name: body
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 主体top程序，调用其他模块实现功能。
// 
//////////////////////////////////////////////////////////////////////////////////

module body(
    input btnc,
    input clk,
    input rst,
    output [3:0] led_sel_n,
    output [6:0] led_segs_n,
    output led_dp,
    output over_flow
    );
    
    wire work,clear,pulse_10ms,pulse_1ms,pulse_200hz,btn_out;
    wire[3:0] bcd_a;
    wire[3:0] bcd_b;
    wire[3:0] bcd_c;
    wire[3:0] bcd_d;
    
    entime#(.N(1000_000)) ENTIME1(.clk(clk),.pulse_output(pulse_10ms));//10ms1000_000
    entime#(.N(100_000)) ENTIME2(.clk(clk),.pulse_output(pulse_1ms));//1ms100_000
    entime#(.N(500_000)) ENTIME3(.clk(clk),.pulse_output(pulse_200hz));//200Hz50_000
        
    counter COUNTER(.work(work),.clear(clear),.pulse_1ms(pulse_1ms),
                    .bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.over_flow(over_flow));
    controller CONTROLLER(.btnc(btnc),.rst(rst),.clk(clk),.pulse_10ms(pulse_10ms),
                          .work(work),.clear(clear));
    Vr7display DISPLAY(.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),
                       .bcd_dp(4'b1011),.clk(pulse_200hz),.rst(0),.ena(1),
                       .led_sel_n(led_sel_n),.led_segs_n(led_segs_n),.led_dp(led_dp));
    
endmodule
```

## 四、管脚约束

```verilog
set_property PACKAGE_PIN U18 [get_ports btnc]

set_property PACKAGE_PIN W7 [get_ports {led_segs_n[6]}]
set_property PACKAGE_PIN W6 [get_ports {led_segs_n[5]}]
set_property PACKAGE_PIN U8 [get_ports {led_segs_n[4]}]
set_property PACKAGE_PIN V8 [get_ports {led_segs_n[3]}]
set_property PACKAGE_PIN U5 [get_ports {led_segs_n[2]}]
set_property PACKAGE_PIN V5 [get_ports {led_segs_n[1]}]
set_property PACKAGE_PIN W4 [get_ports {led_sel_n[3]}]
set_property PACKAGE_PIN V4 [get_ports {led_sel_n[2]}]
set_property PACKAGE_PIN U4 [get_ports {led_sel_n[1]}]
set_property PACKAGE_PIN U2 [get_ports {led_sel_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segs_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_sel_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_sel_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_sel_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_sel_n[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports btnc]
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN V7 [get_ports led_dp]
set_property IOSTANDARD LVCMOS33 [get_ports led_dp]
set_property PACKAGE_PIN U7 [get_ports {led_segs_n[0]}]
set_property PACKAGE_PIN U16 [get_ports over_flow]
set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports over_flow]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
```

## 五、小结及改进建议

​	实验中我在计时模块和七段数码管的没有使用全局的时钟，而是直接使用了使能发生模块的输出作为局部时钟，虽然在本实验中没有出现明显错误，但这并不很符合同步时序电路的原则。很可能降低计时精度，在一定情况下也可能引起错误。

​	改进的想法是：用全局时钟clk，并将pulse_1ms和pulse_200hz作为使能信号，在使能信号为高电平的时候进行操作。

