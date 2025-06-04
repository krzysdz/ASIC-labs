from decimal import Decimal
from pathlib import Path
import re
from dataclasses import dataclass

REPORTS_PATH = Path(__file__).parent.joinpath("./asic_lab3/lab/reports")
STAGES = [
    "initial_map",
    "logic_opto",
    "initial_place",
    "initial_drc",
    "initial_opto",
    "final_place",
    "final_opto",
]

table = [
    "| Parameter |",
    "| -- |",
    "| **Total power (\\unit{\\pico\\watt})** |",
    "| **- Dynamic power (\\unit{\\pico\\watt})** |",
    "| **- Leakage power (\\unit{\\pico\\watt})** |",
    "| **Critical path length (\\unit{\\ns})** |",
    "| **Worst setup slack (\\unit{\\ns})** |",
    "| **Worst hold slack (\\unit{\\ns})** |",
    "| **Chip area** |",
    "| **Total cell area** |",
    "| **- Combinational area** |",
    "| **- Noncombinational area** |",
    "| **Number of nets** |",
    "| **Number of cells** |",
    "| **- Number of buffers** |",
    "| **- Number of inverters** |",
    "| **Levels of logic** |",
    "| **Nets with DRC violations** |",
]

def wrap_cell(data: str | Decimal | int) -> str:
    if isinstance(data, Decimal):
        data = f"\\num{{{data}}}"
    return f" {data} |"

@dataclass
class StageDetails:
    stage: str
    total_power: Decimal
    dynamic_power: Decimal
    leakage_power: Decimal
    crit_len: Decimal
    setup_slack: Decimal
    hold_slack: Decimal
    chip_area: Decimal
    total_area: Decimal
    comb_area: Decimal
    nc_area: Decimal
    n_nets: int
    n_cells: int
    n_buffers: int
    n_inverters: int
    levels: int
    violations: int

    def __init__(self, stage: str) -> None:
        self.stage = stage

    def to_table_cells(self) -> list[str]:
        return [
            wrap_cell(self.stage),
            wrap_cell("-"),
            wrap_cell(self.total_power),
            wrap_cell(self.dynamic_power),
            wrap_cell(self.leakage_power),
            wrap_cell(self.crit_len),
            wrap_cell(self.setup_slack),
            wrap_cell(self.hold_slack),
            wrap_cell(self.chip_area),
            wrap_cell(self.total_area),
            wrap_cell(self.comb_area),
            wrap_cell(self.nc_area),
            wrap_cell(self.n_nets),
            wrap_cell(self.n_cells),
            wrap_cell(self.n_buffers),
            wrap_cell(self.n_inverters),
            wrap_cell(self.levels),
            wrap_cell(self.violations),
        ]

# In retrospect, I should have written a single regex for each report with multiple groups
re_power_total = re.compile(
    r"^Total(?:\s+\d\.\d+e\+\d+ pW){3}\s+(\d\.\d+e\+\d+) pW", re.M
)
re_power_dynamic = re.compile(r"^Total Dynamic Power\s+=\s+(\d\.\d+e\+\d+) pW", re.M)
re_power_leakage = re.compile(r"^Cell Leakage Power\s+=\s+(\d\.\d+e\+\d+) pW", re.M)
re_setup_slack = re.compile(r"^  slack \(\w+\)\s+(-?\d+\.\d+)$", re.M)
re_setup_delay = re.compile(r"^  data arrival time\s+(\d+\.\d+)\n\n", re.M)
re_hold_slack = re_setup_slack
re_design_chip_area = re.compile(r"^Chip Area\s+: (\d+\.\d+)$", re.M)
re_area_total = re.compile(r"^Total cell area:\s+(\d+\.\d+)$", re.M)
re_area_comb = re.compile(r"^Combinational area:\s+(\d+\.\d+)$", re.M)
re_area_nc = re.compile(r"^Noncombinational area:\s+(\d+\.\d+)$", re.M)
re_area_nets = re.compile(r"^Number of nets:\s+(\d+)$", re.M)
re_area_cells = re.compile(r"^Number of cells:\s+(\d+)$", re.M)
re_qor_levels = re.compile(r"^Levels of Logic:\s+(\d+)", re.M)
re_qor_delay = re.compile(r"^Critical Path Length:\s+(\d+\.\d+)", re.M)
re_qor_slack = re.compile(r"^Critical Path Slack:\s+(\d+\.\d+)", re.M)
re_qor_cells = re.compile(r"^Leaf Cell Count:\s+(\d+)$", re.M)
re_qor_buffers = re.compile(r"^Buf Cell Count:\s+(\d+)$", re.M)
re_qor_inverters = re.compile(r"^Inv Cell Count:\s+(\d+)$", re.M)
re_qor_total = re.compile(r"^Cell Area \(netlist\):\s+(\d+\.\d+)", re.M)
re_qor_comb = re.compile(r"^Combinational Area:\s+(\d+\.\d+)", re.M)
re_qor_nc = re.compile(r"^Noncombinational Area:\s+(\d+\.\d+)", re.M)
# re_qor_nets = re.compile(r"^Total Number of Nets:\s+(\d+)$", re.M)
re_qor_violations = re.compile(r"^Nets with Violations:\s+(\d+)$", re.M)

for stage in STAGES:
    details = StageDetails(stage)
    area_rpt_path = REPORTS_PATH / f"{stage}_report_area.rpt"
    area_rpt = area_rpt_path.read_text()
    design_rpt_path = REPORTS_PATH / f"{stage}_report_design.rpt"
    design_rpt = design_rpt_path.read_text()
    power_rpt_path = REPORTS_PATH / f"{stage}_report_power.rpt"
    power_rpt = power_rpt_path.read_text()
    qor_rpt_path = REPORTS_PATH / f"{stage}_report_qor.rpt"
    qor_rpt = qor_rpt_path.read_text()
    timing_hold_rpt_path = REPORTS_PATH / f"{stage}_report_timing_hold.rpt"
    timing_hold_rpt = timing_hold_rpt_path.read_text()
    timing_setup_rpt_path = REPORTS_PATH / f"{stage}_report_timing_setup.rpt"
    timing_setup_rpt = timing_setup_rpt_path.read_text()

    details.total_power = Decimal(re_power_total.search(power_rpt).group(1))
    details.dynamic_power = Decimal(re_power_dynamic.search(power_rpt).group(1))
    details.leakage_power = Decimal(re_power_leakage.search(power_rpt).group(1))
    details.setup_slack = Decimal(re_setup_slack.search(timing_setup_rpt).group(1))
    details.crit_len = Decimal(re_setup_delay.search(timing_setup_rpt).group(1))
    details.hold_slack = Decimal(re_hold_slack.search(timing_hold_rpt).group(1))
    details.chip_area = Decimal(re_design_chip_area.search(design_rpt).group(1))
    details.total_area = Decimal(re_area_total.search(area_rpt).group(1))
    details.comb_area = Decimal(re_area_comb.search(area_rpt).group(1))
    details.nc_area = Decimal(re_area_nc.search(area_rpt).group(1))
    details.n_nets = int(re_area_nets.search(area_rpt).group(1))
    details.n_cells = int(re_area_cells.search(area_rpt).group(1))
    details.n_buffers = int(re_qor_buffers.search(qor_rpt).group(1))
    details.n_inverters = int(re_qor_inverters.search(qor_rpt).group(1))
    details.levels = int(re_qor_levels.search(qor_rpt).group(1))
    assert(details.crit_len == Decimal(re_qor_delay.search(qor_rpt).group(1)))
    assert(details.setup_slack == Decimal(re_qor_slack.search(qor_rpt).group(1)))
    assert(details.n_cells == int(re_qor_cells.search(qor_rpt).group(1)))
    assert(details.total_area == Decimal(re_qor_total.search(qor_rpt).group(1)))
    assert(details.comb_area == Decimal(re_qor_comb.search(qor_rpt).group(1)))
    assert(details.nc_area == Decimal(re_qor_nc.search(qor_rpt).group(1)))
    # assert(details.n_nets == int(re_qor_nets.search(qor_rpt).group(1)))
    details.violations = int(re_qor_violations.search(qor_rpt).group(1))

    for i, cell in enumerate(details.to_table_cells()):
        table[i] = table[i] + cell

print("\n".join(table))
