//! Universal Asynchronous Receiver/Transmitter
//!
//! See FE310-G002 manual v1p1, Chapter 18

const Register = @import("../../../mmio_register.zig").Register;

pub const Uart0 = Uart(0x1001_3000);
pub const Uart1 = Uart(0x1002_3000);

fn Uart(base_address: usize) type {
    return struct {
        pub fn setBaudRate() void {
            // For now, hardcode to 115200 assuming a 16 MHz tlclk.
            // Value is from the manual, Section 18.9 Table 62.
            div.modify(.{
                .div = 138,
            });
        }

        pub fn enableTx() void {
            txctrl.modify(.{
                .txen = true,
            });
        }

        pub fn writeString(string: []const u8) void {
            for (string) |c| {
                writeByte(c);
            }
        }

        pub fn writeByte(byte: u8) void {
            // Wait for TX FIFO to have space available.
            while (txdata.read().full) {}

            // Write the byte to the TX FIFO.
            txdata.write(.{
                .data = byte,
            });
        }

        /// Writing to the txdata register enqueues the character contained in
        /// the data field to the transmit FIFO if the FIFO is able to accept
        /// new entries. Reading from txdata returns the current value of the
        /// full flag and zero in the data field. The full flag indicates
        /// whether the transmit FIFO is able to accept new entries; when set,
        /// writes to data are ignored. A RISC‑V amoor.w instruction can be used
        /// to both read the full status and attempt to enqueue data, with a
        /// non-zero return value indicating the character was not accepted.
        const txdata = Register(u32, packed struct {
            /// Transmit data (RW)
            data: u9, // TODO: Should be u8 but that makes the size of this struct 5 bytes for some reason.
            _reserved_8: u22 = 0,
            /// Transmit FIFO full (RO)
            full: bool = false,
        }).init(base_address + 0x0);

        /// Reading the rxdata register dequeues a character from the receive
        /// FIFO and returns the value in the data field. The empty flag
        /// indicates if the receive FIFO was empty; when set, the data field
        /// does not contain a valid character. Writes to rxdata are ignored.
        const rxdata = Register(u32, packed struct {
            /// Received data (RO)
            data: u8,
            _reserved_8: u23,
            /// Receive FIFO empty (RO)
            empty: bool,
        }).init(base_address + 0x4);

        /// The read-write txctrl register controls the operation of the
        /// transmit channel. The txen bit controls whether the Tx channel
        /// is active. When cleared, transmission of Tx FIFO contents is
        /// suppressed, and the txd pin is driven high.
        const txctrl = Register(u32, packed struct {
            /// Transmit enable (RW)
            txen: bool,
            /// Number of stop bits (RW)
            nstop: enum(u1) {
                one = 0,
                two = 1,
            },
            _reserved_2: u14,
            /// Transmit watermark level (RW)
            /// The threshold at which the TX FIFO watermark interrupt triggers.
            txcnt: u3,
            _reserved_19: u13,
        }).init(base_address + 0x08);

        /// The read-write rxctrl register controls the operation of the receive
        /// channel. The rxen bit controls whether the Rx channel is active.
        /// When cleared, the state of the rxd pin is ignored, and no
        /// characters will be enqueued into the Rx FIFO.
        const rxctrl = Register(u32, packed struct {
            /// Receive enable (RW)
            rxen: bool,
            /// Number of stop bits (RW)
            nstop: enum(u1) {
                one = 0,
                two = 1,
            },
            _reserved_2: u14,
            /// Receive watermark level (RW)
            /// The threshold at which the RX FIFO watermark interrupt triggers.
            rxcnt: u3,
            _reserved_19: u13,
        }).init(base_address + 0x0C);

        /// The read-write ie register controls which UART interrupts are
        /// enabled.
        ///
        /// The txwm condition becomes raised when the number of entries in
        /// the transmit FIFO is strictly less than the count specified by the
        /// txcnt field of the txctrl register. The pending bit is cleared when
        /// sufficient entries have been enqueued to exceed the watermark.
        ///
        /// The rxwm condition becomes raised when the number of entries in the
        /// receive FIFO is strictly greater than the count specified by the
        /// rxcnt field of the rxctrl register. The pending bit is cleared when
        /// sufficient entries have been dequeued to fall below the watermark.
        const ie = Register(u32, packed struct {
            /// Transmit watermark interrupt enable.
            txwm: bool,
            /// Receive watermark interrupt enable.
            rxwm: bool,
            _reserved_2: u30,
        }).init(base_address + 0x10);

        /// The ip register is a read-only register indicating the pending
        /// interrupt conditions. See ie for more details.
        const ip = Register(u32, packed struct {
            /// Transmit watermark interrupt pending.
            txwm: bool,
            /// Receive watermark interrupt pending.
            rxwm: bool,
            _reserved_2: u30,
        }).init(base_address + 0x14);

        const div = Register(u32, packed struct {
            /// Baud rate divisor.
            div: u16,
            _reserved_16: u16,
        }).init(base_address + 0x18);
    };
}
