#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Extract a concise readable summary from the batch output CSV."""
import csv
import sys

batch_num = int(sys.argv[1]) if len(sys.argv) > 1 else 1
input_file = f'/home/heiba/EGX360 Graduation Project/sentiment analysis/batch{batch_num}_output.csv'
output_file = f'/home/heiba/EGX360 Graduation Project/sentiment analysis/batch{batch_num}_summary.txt'

with open(input_file, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    rows = list(reader)

with open(output_file, 'w', encoding='utf-8') as out:
    out.write(f"Batch {batch_num} - Sentiment Analysis Summary\n")
    out.write(f"Total rows: {len(rows)}\n")
    out.write("=" * 80 + "\n")
    
    counts = {'Positive': 0, 'Negative': 0, 'Neutral': 0}
    
    for i, row in enumerate(rows, 1):
        title = row.get('title', '')
        # clean up the title (remove extra newlines)
        title_clean = ' '.join(title.replace('\n', ' ').replace('\r', ' ').split())[:80]
        label = row.get('sentiment_label', 'Unknown')
        stock_id = row.get('stock_id', '')
        counts[label] = counts.get(label, 0) + 1
        out.write(f"{i:3}. [stock_id={stock_id}] {label:8} | {title_clean}\n")
    
    out.write("\n" + "=" * 80 + "\n")
    out.write(f"SENTIMENT DISTRIBUTION:\n")
    for k, v in counts.items():
        out.write(f"  {k}: {v} ({v/len(rows)*100:.1f}%)\n")

print(f"Summary written to: {output_file}")
print(f"Total rows: {len(rows)}")
