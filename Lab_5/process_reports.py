import re
from dataclasses import dataclass
from decimal import Decimal
from pathlib import Path
from typing import Any, Literal, Tuple
from typing import get_args as get_type_args

REPORTS_PATH = Path(__file__).parent.joinpath("./asic_lab5/lab/reports")
# # Task 2:
# VERSIONS = [
#     "classic_placement",
#     "unified_placement",
#     "placement_with_blockage",
#     "rerun_placement_with_blockage",
# ]
# VERSION_NAMES = ["classic", "unified", "with blockage", "with blockage (rerun)"]

# # Task 3:
# VERSIONS = [
#     "clock_tree_synthesis",
# ]
# VERSION_NAMES = ["clock tree synthesis"]

# # Task 4:
# VERSIONS = [
#     "routing_with_blockage",
# ]
# VERSION_NAMES = ["routing with blockage"]

# Task 5:
VERSIONS = [
    "signoff",
]
VERSION_NAMES = VERSIONS

assert len(VERSIONS) == len(VERSION_NAMES)

type KnownReport = Literal[
    "check_legality",
    "report_area",
    "report_congestion",
    "report_design",
    "report_power",
    "report_qor",
    "report_timing_hold",
    "report_timing_setup",
    "report_utilization",
]
KNOWN_REPORTS: Tuple[KnownReport, ...] = get_type_args(KnownReport)


@dataclass
class Parameter[T: (int, Decimal)]:
    name: str
    """Parameter name shown in table (can use markdown and LaTeX)"""
    report_file: KnownReport
    """Report file suffix e.g. report_area or check_legality"""
    regex: re.Pattern[str]
    """Pattern used for parameter data extraction. The first group is extracted."""
    type: type[T]
    """What should be the type of extracted data"""

    def parse_from_report(self, data: str) -> T:
        match_result = self.regex.search(data)
        assert match_result is not None
        extracted = match_result.group(1)
        assert isinstance(extracted, str)
        return self.type(extracted)

    def find_in_reports(self, reports: dict[KnownReport, str]) -> T:
        return self.parse_from_report(reports[self.report_file])


regex_data_arrival = re.compile(r"^  slack \(\w+\)\s+(-?\d+\.\d+)$", re.M)

PARAM_LIST: list[Parameter[Any]] = [
    Parameter(
        "Legality violations",
        "check_legality",
        re.compile(r"^TOTAL (\d+) Violations.$", re.M),
        int,
    ),
    Parameter(
        "Total overflow",
        "report_congestion",
        re.compile(r"^Both Dirs \|\s+(\d+) \|", re.M),
        int,
    ),
    Parameter(
        "Overflowing GRCs %",
        "report_congestion",
        re.compile(
            r"^Both Dirs \|\s+\d+ \|\s+\d+ \|\s+\d+\s+\(\s+(\d+\.\d+)%\) \|", re.M
        ),
        Decimal,
    ),
    Parameter(
        "Utilization ratio",
        "report_utilization",
        re.compile(r"^Utilization Ratio:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "Chip area",
        "report_design",
        re.compile(r"^Chip Area\s+: (\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "Core area",
        "report_utilization",
        re.compile(r"^Total Area:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "- Excluded area",
        "report_utilization",
        re.compile(r"^Total Area of excluded objects:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "- Total cell area",
        "report_utilization",
        re.compile(r"^Total Area of cells:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        r"\|  - Combinational area",
        "report_area",
        re.compile(r"^Combinational area:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        r"\|  - Noncombinational area",
        "report_area",
        re.compile(r"^Noncombinational area:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "Power (Normal\\_Typical) (\\unit{\\pico\\watt})",
        "report_power",
        re.compile(
            r"^Scenario: Normal_Typical\n[\w\W]+?\nTotal(?:\s+\d\.\d+e\+\d+ pW){3}\s+(\d\.\d+e\+\d+) pW",
            re.M,
        ),
        Decimal,
    ),
    Parameter(
        "- Dynamic power (\\unit{\\pico\\watt})",
        "report_power",
        re.compile(
            r"^Scenario: Normal_Typical\n[\w\W]+?\nTotal Dynamic Power\s+=\s+(\d\.\d+e\+\d+) pW",
            re.M,
        ),
        Decimal,
    ),
    Parameter(
        r"\|  - Cell internal power (\unit{\pico\watt})",
        "report_power",
        re.compile(
            r"^Scenario: Normal_Typical\n[\w\W]+?\n\s*Cell Internal Power\s+=\s+(\d\.\d+e\+\d+) pW",
            re.M,
        ),
        Decimal,
    ),
    Parameter(
        r"\|  - Net switching power (\unit{\pico\watt})",
        "report_power",
        re.compile(
            r"^Scenario: Normal_Typical\n[\w\W]+?\n\s*Net Switching Power\s+=\s+(\d\.\d+e\+\d+) pW",
            re.M,
        ),
        Decimal,
    ),
    Parameter(
        "- Leakage power (\\unit{\\pico\\watt})",
        "report_power",
        re.compile(
            r"^Scenario: Normal_Typical\n[\w\W]+?\nCell Leakage Power\s+=\s+(\d\.\d+e\+\d+) pW",
            re.M,
        ),
        Decimal,
    ),
    Parameter(
        "Critical path length (\\unit{\\ns})",
        "report_timing_setup",
        re.compile(r"^  data arrival time\s+(\d+\.\d+)\n\n", re.M),
        Decimal,
    ),
    Parameter(
        "Worst setup slack (\\unit{\\ns})",
        "report_timing_setup",
        regex_data_arrival,
        Decimal,
    ),
    Parameter(
        "Worst hold slack (\\unit{\\ns})",
        "report_timing_hold",
        regex_data_arrival,
        Decimal,
    ),
    Parameter(
        "Net length",
        "report_qor",
        re.compile(r"^Net Length:\s+(\d+\.\d+)$", re.M),
        Decimal,
    ),
    Parameter(
        "Number of nets",
        "report_area",
        re.compile(r"^Number of nets:\s+(\d+)$", re.M),
        int,
    ),
    Parameter(
        "Number of cells",
        "report_area",
        re.compile(r"^Number of cells:\s+(\d+)$", re.M),
        int,
    ),
    Parameter(
        "- Number of buffers",
        "report_qor",
        re.compile(r"^Buf Cell Count:\s+(\d+)$", re.M),
        int,
    ),
    Parameter(
        "- Number of inverters",
        "report_qor",
        re.compile(r"^Inv Cell Count:\s+(\d+)$", re.M),
        int,
    ),
]


def required_report_types() -> set[KnownReport]:
    return set(p.report_file for p in PARAM_LIST)


def get_version_reports(version: str) -> dict[KnownReport, str]:
    return dict(
        (r, REPORTS_PATH.joinpath(f"{version}_{r}.rpt").read_text())
        for r in required_report_types()
    )


def get_version_data(version: str) -> list[int | Decimal]:
    reports = get_version_reports(version)
    return [p.find_in_reports(reports) for p in PARAM_LIST]


def wrap_cell(data: str | Decimal | int) -> str:
    if isinstance(data, Decimal):
        data = f"\\num{'[retain-negative-zero]' if data == Decimal("-0") else ''}{{{data}}}"
    return f" {data} |"


def generate_table() -> str:
    header = ["| Parameter |"] + [wrap_cell(v) for v in VERSION_NAMES]
    separator = ["| :--- |"] + [" -: |"] * len(VERSIONS)
    data_rows = [[f"| **{p.name}** |"] for p in PARAM_LIST]
    for version in VERSIONS:
        for i, data in enumerate(get_version_data(version)):
            data_rows[i].append(wrap_cell(data))
    table_rows = [header] + [separator] + data_rows
    return "\n".join("".join(row) for row in table_rows)


if __name__ == "__main__":
    print(generate_table())
