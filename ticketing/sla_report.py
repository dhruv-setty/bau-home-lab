#!/usr/bin/env python3
"""SLA report for a ticket queue CSV. Usage: python3 sla_report.py tickets.csv [now]"""
import csv, sys
from datetime import datetime, timedelta

FMT = "%Y-%m-%d %H:%M"
MATRIX = {("High", "High"): "P1", ("High", "Medium"): "P2", ("High", "Low"): "P3",
          ("Medium", "High"): "P2", ("Medium", "Medium"): "P3", ("Medium", "Low"): "P4",
          ("Low", "High"): "P3", ("Low", "Medium"): "P4", ("Low", "Low"): "P4"}
# (first response minutes, resolution minutes, 24x7 clock)
SLA = {"P1": (15, 240, True), "P2": (30, 480, False),
       "P3": (240, 3 * 540, False), "P4": (540, 5 * 540, False)}
DAY_START, DAY_END = 8, 17

def minutes_between(start, end, always_on):
    if end <= start:
        return 0
    if always_on:
        return int((end - start).total_seconds() // 60)
    total, t = 0, start
    while t < end:
        day_open = t.replace(hour=DAY_START, minute=0, second=0)
        day_close = t.replace(hour=DAY_END, minute=0, second=0)
        if t.weekday() < 5 and t < day_close:
            seg_start, seg_end = max(t, day_open), min(end, day_close)
            if seg_end > seg_start:
                total += int((seg_end - seg_start).total_seconds() // 60)
        t = (t + timedelta(days=1)).replace(hour=0, minute=0)
    return total

def fmt(m):
    return f"{m // 60}h {m % 60:02d}m"

def main():
    path = sys.argv[1]
    now = datetime.strptime(sys.argv[2], FMT) if len(sys.argv) > 2 else datetime.now()
    rows = list(csv.DictReader(open(path)))
    print(f"{'Ticket':<9}{'Pri':<4}{'Response':<20}{'Resolution':<24}{'Status':<10}Summary")
    counts = {}
    for r in rows:
        pri = MATRIX[(r["impact"], r["urgency"])]
        resp_t, res_t, always_on = SLA[pri]
        opened = datetime.strptime(r["opened"], FMT)
        first = datetime.strptime(r["first_response"], FMT) if r["first_response"] else now
        end = datetime.strptime(r["resolved"], FMT) if r["resolved"] else now
        resp = minutes_between(opened, first, always_on)
        res = max(0, minutes_between(opened, end, always_on) - int(r["pending_minutes"] or 0))
        if resp > resp_t or res > res_t:
            status = "Breached"
        elif not r["resolved"] and res >= 0.75 * res_t:
            status = "At risk"
        elif not r["resolved"]:
            status = "Open"
        else:
            status = "Met"
        counts[status] = counts.get(status, 0) + 1
        print(f"{r['id']:<9}{pri:<4}{fmt(resp) + ' / ' + fmt(resp_t):<20}"
              f"{fmt(res) + ' / ' + fmt(res_t):<24}{status:<10}{r['summary']}")
    print("\n" + ", ".join(f"{k}: {v}" for k, v in sorted(counts.items())))

if __name__ == "__main__":
    main()
