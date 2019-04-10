from nmigen import *
from nmigen.back import verilog, pysim

class SAADC:
    def __init__(self, N):
        self.N = N
        self.dac_out = Signal(self.N, reset=(1 << (self.N - 1)))
        self.out = Signal(self.N)
        self.bit = Signal(max=self.N, reset=self.N - 1)
        self.comparator_input = Signal()
        self.output_valid = Signal()

    def elaborate(self, platform):
        m = Module()
        mask_full = (1 << self.N) - 1


        # m.d.sync += Array(self.out)[self.bit].eq(self.comparator_input)
        with m.If(self.comparator_input == 0):
            m.d.sync += self.out.eq(self.out & ~(1 << (self.bit)))
        with m.Else():
            m.d.sync += self.out.eq(self.out | (1 << (self.bit)))

        with m.If(self.bit == 0):
            m.d.sync += self.output_valid.eq(1)
            m.d.sync += self.bit.eq(self.N - 1)
        with m.Else():
            m.d.sync += self.bit.eq(self.bit - 1)
            m.d.sync += self.output_valid.eq(0)

        m.d.comb += self.dac_out.eq((self.out | (1 << self.bit)) & (mask_full << self.bit))

        return m


N = 6
controller = SAADC(N=N)
with open("gateware.v", "w") as f:
    f.write(verilog.convert(
        controller.elaborate(platform=None),
        name="controller", 
        ports=[controller.dac_out, controller.out, controller.comparator_input, controller.output_valid]))


import random

class TestBench:
    def __init__(self, N):
        self.N = N
        self.value = Signal(N)
        self.controller = SAADC(N)

    def elaborate(self, platform):
        m = Module()
        m.submodules += self.controller
        m.d.comb += self.controller.comparator_input.eq(self.controller.dac_out <= self.value)

        return m

test = TestBench(N = N)
with pysim.Simulator(test,
        vcd_file=open("gateware.vcd", "w"),
        gtkw_file=open("gateware.gtkw", "w"),
        traces=[test.controller.dac_out, test.controller.out, test.controller.comparator_input, test.controller.bit, test.controller.output_valid]) as sim:
    sim.add_clock(1e-6)
    def controller_proc():
        values = list(range(2**N))
        random.shuffle(values)
        got_index = 0
        first = True

        yield test.value.eq(values[0])
        for i in range(0, N-1):
            yield

        for value in values:
            yield test.value.eq(value)
            for i in range(0, N):
                yield
                if (yield test.controller.output_valid):
                    if not first:
                        assert((yield test.controller.out) == values[got_index])
                        got_index += 1
                    else:
                        first = False

        yield
        if (yield test.controller.output_valid):
            assert((yield test.controller.out) == values[got_index])
            got_index += 1

                
    sim.add_sync_process(controller_proc())
    sim.run_until(1000e-6, run_passive=False)
