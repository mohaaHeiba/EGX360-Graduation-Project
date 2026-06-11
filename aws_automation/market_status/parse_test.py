import re

def format_large_number(num_str, multiply_by_1000=False):
    try:
        clean = float(re.sub(r'[^\d.]', '', num_str))
        if multiply_by_1000:
            clean *= 1000 
            
        if clean >= 1_000_000_000_000:
            return f"{clean / 1_000_000_000_000:.2f}T EGP"
        elif clean >= 1_000_000_000:
            return f"{clean / 1_000_000_000:.2f}B EGP"
        elif clean >= 1_000_000:
            return f"{clean / 1_000_000:.2f}M EGP"
        else:
            return f"{clean:,.0f} EGP"
    except:
        return num_str

print(format_large_number(""))
print(format_large_number("1,800,000,000,000"))
