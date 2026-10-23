# SinLab

[简体中文](#简体中文) | [English](#english)

## 简体中文

SinLab 是一个基于 FPGA 的正弦信号发生与测量工程。工程使用 Xilinx DDS Compiler 生成正弦波，并通过 XADC 采集外部模拟信号；频率和幅度结果可在 Nexys A7 的八位数码管上显示，也会通过 UART 周期性发送。

### 功能

- **DDS 信号发生**：按键调节输出频率（1–9999 kHz）和幅度（0–100%）。
- **ADC 测量**：通过 XADC 的 VAUX3 通道采集模拟输入，测量信号频率和幅度。
- **数据显示**：使用开关 `switch[0]` 选择显示 ADC 测量值或 DDS 设定值；数码管显示频率和幅度。
- **状态指示**：LED 指示 ADC 数据、频率测量和幅度测量状态。
- **UART 输出**：周期性发送频率和幅度读数，串口发送模块按 100 MHz 时钟和 115200 baud 配置。

### 硬件与工具

| 项目 | 配置 |
| --- | --- |
| FPGA 器件 | `xc7a100tcsg324-1` |
| 目标开发板 | Nexys A7-100T（工程约束文件中的板卡标注） |
| 时钟 | 100 MHz |
| 工程文件 | `SineLab.xpr` |
| 工程创建时使用的 Vivado | 2025.2 |

工程包含 DDS Compiler、XADC Wizard 和 ILA 的 Vivado IP 配置文件。打开工程后，如 IP 输出产品尚未生成，请在 Vivado 中运行 **Generate Output Products**。

### 工程结构

```text
SineLab.xpr
SineLab.srcs/
├── sources_1/
│   ├── new/                         # ADC、DDS、显示选择、数值转换及 UART RTL
│   ├── ip/                          # DDS Compiler、XADC Wizard、ILA 的 .xci 配置
│   └── imports/                     # 测量、数码管及顶层 RTL
├── constrs_1/imports/new/
│   └── sinlab_top.xdc               # 引脚与时钟约束
└── sim_1/                           # 仿真 testbench
```

当前 Vivado 工程的综合顶层设置为 `sinlab_top`。主要顶层及功能模块包括：

- `sinlab_top`：连接 ADC 测量、DDS 发生、数据显示和 UART。
- `ADC_measure`、`freq_measure`、`amplitude_measure`：ADC 采集及频率/幅度测量。
- `Sine_generate`、`dds_controller`：DDS 参数控制和波形幅度缩放。
- `selector`、`bin2bcd`、`seg7_driver`：数据选择、BCD 转换和数码管扫描驱动。
- `uart_interface`、`uart_byte_tx`：周期性读数格式化及串口发送。

### 在 Vivado 中打开

1. 克隆或下载本仓库。
2. 使用 Vivado 打开仓库根目录下的 `SineLab.xpr`。
3. 确认器件为 `xc7a100tcsg324-1`，并检查工程中的 IP 是否已生成输出产品。
4. 在 **Sources** 中确认综合顶层为 `sinlab_top`，再运行综合或仿真。

仿真 testbench 位于 `SineLab.srcs/sim_1`。


## English

SinLab is an FPGA-based sine-wave generation and measurement project. It uses the Xilinx DDS Compiler to generate a sine wave and the XADC to sample an external analog signal. Frequency and amplitude readings can be shown on the Nexys A7 eight-digit seven-segment display and are also transmitted periodically over UART.

### Features

- **DDS signal generation**: Use the push buttons to adjust the output frequency (1–9999 kHz) and amplitude (0–100%).
- **ADC measurement**: Sample an analog input through the XADC VAUX3 channel and measure its frequency and amplitude.
- **Display selection**: Use `switch[0]` to select between ADC measurements and DDS settings. The seven-segment display shows frequency and amplitude.
- **Status indicators**: LEDs indicate ADC data, frequency measurement, and amplitude measurement activity.
- **UART output**: Frequency and amplitude readings are transmitted periodically. The UART transmitter is configured for a 100 MHz clock and 115200 baud.

### Hardware and Tools

| Item | Configuration |
| --- | --- |
| FPGA device | `xc7a100tcsg324-1` |
| Target board | Nexys A7-100T (as identified in the project constraints) |
| Clock | 100 MHz |
| Project file | `SineLab.xpr` |
| Vivado version used to create the project | 2025.2 |

The project includes Vivado IP configurations for the DDS Compiler, XADC Wizard, and ILA. If generated IP output products are missing, run **Generate Output Products** in Vivado after opening the project.

### Project Structure

```text
SineLab.xpr
SineLab.srcs/
├── sources_1/
│   ├── new/                         # ADC, DDS, selection, conversion, and UART RTL
│   ├── ip/                          # DDS Compiler, XADC Wizard, and ILA .xci files
│   └── imports/                     # Measurement, display, and top-level RTL
├── constrs_1/imports/new/
│   └── sinlab_top.xdc               # Pin and clock constraints
└── sim_1/                           # Simulation testbenches
```

The synthesis top selected in the current Vivado project is `sinlab_top`. Main top-level and functional modules include:

- `sinlab_top`: Connects ADC measurement, DDS generation, display logic, and UART.
- `ADC_measure`, `freq_measure`, `amplitude_measure`: ADC acquisition and frequency/amplitude measurement.
- `Sine_generate`, `dds_controller`: DDS parameter control and waveform amplitude scaling.
- `selector`, `bin2bcd`, `seg7_driver`: Data selection, binary-to-BCD conversion, and seven-segment scanning.
- `uart_interface`, `uart_byte_tx`: Periodic reading formatting and UART transmission.

### Open the Project in Vivado

1. Clone or download this repository.
2. Open `SineLab.xpr` from the repository root in Vivado.
3. Confirm the device is `xc7a100tcsg324-1` and check that the project's IP output products have been generated.
4. In **Sources**, confirm that `sinlab_top` is the synthesis top, then run synthesis or simulation.

Simulation testbenches are under `SineLab.srcs/sim_1`. 
