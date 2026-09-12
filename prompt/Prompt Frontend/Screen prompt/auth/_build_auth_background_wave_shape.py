"""Build auth_background_wave_shape.svg — finalized ribbon (former wave_edges_4).

Source of truth pairs: Auth Background Wave Shape.md
"""

from pathlib import Path

TEAL_X_3 = [0.0, 0.12, 0.28, 0.42, 0.58, 0.72, 0.88, 1.0]
TEAL_X_2 = [0.0, 0.18, 0.38, 0.62, 0.82, 1.0]
TEAL_X_1 = [0.0, 0.25, 0.50, 0.75, 1.0]  # mid control at x=50%
LIGHT_X_3 = [0.0, 0.10, 0.24, 0.38, 0.52, 0.66, 0.80, 0.92, 1.0]
LIGHT_X_2 = [0.0, 0.16, 0.36, 0.56, 0.76, 0.90, 1.0]
LIGHT_X_1 = [0.0, 0.20, 0.50, 0.72, 0.88, 1.0]

# Keep 1,2,6; mix 3/5; cut 4 = 1 wave
# Language: 2-wave redesign (same X family as other 2-wave cuts)
TEAL_X_LANG = TEAL_X_2
LIGHT_X_LANG = LIGHT_X_2

TEAL_XS = [TEAL_X_LANG, TEAL_X_2, TEAL_X_2, TEAL_X_1, TEAL_X_2, TEAL_X_2]
LIGHT_XS = [LIGHT_X_LANG, LIGHT_X_2, LIGHT_X_2, LIGHT_X_1, LIGHT_X_2, LIGHT_X_2]

TEAL_SEAMS = [0.360, 0.400, 0.500, 0.500, 0.400, 0.240, 0.200]
# Light seam at cut3→4 (index 3): was 0.575; gap vs teal 0.50 was 0.075 → half → 0.5375
LIGHT_SEAMS = [0.410, 0.460, 0.560, 0.538, 0.455, 0.300, 0.270]

TEAL_INTERIOR = [
    # 1 Language — 2 waves: early drop @~18% → BIG crest → ease to 40%
    #   x: 0.18  0.38  0.62  0.82
    [0.390, 0.335, 0.415, 0.375],
    # 2 Onboarding_1 — KEEP
    [0.385, 0.430, 0.415, 0.470],
    # 3 Onboarding_2 — KEEP
    [0.480, 0.520, 0.485, 0.510],
    # 4 Onboarding_3 — KEEP (softer mid rise)
    [0.515, 0.428, 0.420],
    # 5 Sign In — KEEP
    [0.340, 0.290, 0.325, 0.265],
    # 6 Sign Up — KEEP
    [0.215, 0.255, 0.205, 0.230],
]

LIGHT_INTERIOR = [
    # 1 Language — 2 waves, gap breathes
    [0.435, 0.380, 0.465, 0.420, 0.450],
    # 2–6 KEEP
    [0.430, 0.480, 0.460, 0.520, 0.545],
    [0.535, 0.575, 0.540, 0.560, 0.555],
    [0.570, 0.480, 0.475, 0.460],
    [0.400, 0.350, 0.385, 0.320, 0.295],
    [0.265, 0.310, 0.250, 0.285, 0.255],
]

LABELS = [
    ("1 Language", "2 waves · 36→40%"),
    ("2 Onboarding_1", "2 waves · quieter · 40→50%"),
    ("3 Onboarding_2", "2 waves · quieter · ~50%"),
    ("4 Onboarding_3", "1 wave · softer rise @50%"),
    ("5 Sign In", "2 waves · 40→24%"),
    ("6 Sign Up", "2 waves · 24→20%"),
]

CUTS = 6
# iPhone 16 Pro Max logical viewport — each cut = one phone screen
SEG_W = 440
H = 956
TOTAL_W = SEG_W * CUTS  # 2640 = 6 × 440
TOP = 96
TEAL = "#08B9B3"
LIGHT = "#A8E6E3"
WHITE = "#FFFFFF"
BG = "#F3F4F6"

GUIDES = [
    (0.20, "20%"),
    (0.24, "24%"),
    (0.31, "31%"),
    (0.36, "36%"),
    (0.40, "40%"),
    (0.50, "50%"),
]


def catmull_fill(points, width):
    d = [f"M 0 0 L {width} 0 L {points[-1][0]:.2f} {points[-1][1]:.2f}"]
    edge = list(reversed(points))
    for i in range(len(edge) - 1):
        p0 = edge[i - 1] if i > 0 else edge[i]
        p1 = edge[i]
        p2 = edge[i + 1]
        p3 = edge[i + 2] if i + 2 < len(edge) else edge[i + 1]
        cp1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        cp2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d.append(
            f"C {cp1[0]:.2f} {cp1[1]:.2f} {cp2[0]:.2f} {cp2[1]:.2f} {p2[0]:.2f} {p2[1]:.2f}"
        )
    d.append("Z")
    return " ".join(d)


def edge_stroke(points):
    d = [f"M {points[0][0]:.2f} {points[0][1]:.2f}"]
    for i in range(len(points) - 1):
        p0 = points[i - 1] if i > 0 else points[i]
        p1 = points[i]
        p2 = points[i + 1]
        p3 = points[i + 2] if i + 2 < len(points) else points[i + 1]
        cp1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        cp2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d.append(
            f"C {cp1[0]:.2f} {cp1[1]:.2f} {cp2[0]:.2f} {cp2[1]:.2f} {p2[0]:.2f} {p2[1]:.2f}"
        )
    return " ".join(d)


def build_ribbon(xs_per_cut, seams, interiors):
    pts = []
    for i in range(CUTS):
        xs = xs_per_cut[i]
        ys = [seams[i]] + list(interiors[i]) + [seams[i + 1]]
        assert len(ys) == len(xs), (len(ys), len(xs), i)
        for j, (lx, ly) in enumerate(zip(xs, ys)):
            if i > 0 and j == 0:
                continue
            pts.append((i * SEG_W + lx * SEG_W, ly * H))
    return pts


def main():
    teal_pts = build_ribbon(TEAL_XS, TEAL_SEAMS, TEAL_INTERIOR)
    light_pts = build_ribbon(LIGHT_XS, LIGHT_SEAMS, LIGHT_INTERIOR)

    labels = []
    for i, (title, sub) in enumerate(LABELS):
        cx = i * SEG_W + SEG_W / 2
        labels.append(
            f'<text x="{cx:.1f}" y="-32" text-anchor="middle" font-size="15" '
            f'font-weight="700" font-family="Segoe UI,sans-serif" fill="#222">{title}</text>'
            f'<text x="{cx:.1f}" y="-12" text-anchor="middle" font-size="12" '
            f'font-family="Segoe UI,sans-serif" fill="#555">{sub}</text>'
        )

    cuts = []
    frames = []
    for i in range(CUTS):
        x = i * SEG_W
        frames.append(
            f'<rect x="{x}" y="0" width="{SEG_W}" height="{H}" fill="none" '
            f'stroke="#111" stroke-width="2" opacity="0.35"/>'
            f'<text x="{x + 12}" y="{H - 16}" font-size="12" font-family="Segoe UI,sans-serif" '
            f'fill="#6b7280">{SEG_W}×{H}</text>'
        )
    for i in range(1, CUTS):
        x = i * SEG_W
        cuts.append(
            f'<line x1="{x}" y1="0" x2="{x}" y2="{H}" stroke="#111" '
            f'stroke-width="2" stroke-dasharray="6 5" opacity="0.55"/>'
        )

    guides = []
    for yf, label in GUIDES:
        y = yf * H
        guides.append(
            f'<line x1="0" y1="{y:.1f}" x2="{TOTAL_W}" y2="{y:.1f}" '
            f'stroke="#9ca3af" stroke-width="1" stroke-dasharray="2 6" opacity="0.55"/>'
            f'<text x="6" y="{y - 4:.1f}" font-size="10" font-family="Segoe UI,sans-serif" '
            f'fill="#6b7280">{label}</text>'
        )

    seams = []
    for i in range(CUTS + 1):
        x = i * SEG_W
        ty = TEAL_SEAMS[i] * H
        ly = LIGHT_SEAMS[i] * H
        pct = int(round(TEAL_SEAMS[i] * 100))
        seams.append(
            f'<circle cx="{x}" cy="{ty:.1f}" r="4" fill="#e9c46a" stroke="#111" stroke-width="1"/>'
            f'<circle cx="{x}" cy="{ly:.1f}" r="4" fill="#2a9d8f" stroke="#111" stroke-width="1"/>'
            f'<text x="{x + 6}" y="{ty - 6:.1f}" font-size="10" font-weight="600" '
            f'font-family="Segoe UI,sans-serif" fill="#92400e">{pct}%</text>'
        )

    svg_h = TOP + H + 64
    svg = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{TOTAL_W}" height="{svg_h}" viewBox="0 0 {TOTAL_W} {svg_h}">
  <rect width="{TOTAL_W}" height="{svg_h}" fill="{BG}"/>
  <text x="24" y="28" font-size="20" font-weight="700" font-family="Segoe UI,sans-serif" fill="#222">Auth Background Wave Shape — Vithey ribbon (6 pieces)</text>
  <text x="24" y="52" font-size="13" font-family="Segoe UI,sans-serif" fill="#555">iPhone 16 Pro Max · each cut {SEG_W}×{H} · see Auth Background Wave Shape.md</text>
  <g transform="translate(0,{TOP})">
    {"".join(labels)}
    <rect x="0" y="0" width="{TOTAL_W}" height="{H}" fill="{WHITE}"/>
    <path d="{catmull_fill(light_pts, TOTAL_W)}" fill="{LIGHT}" fill-opacity="0.85"/>
    <path d="{catmull_fill(teal_pts, TOTAL_W)}" fill="{TEAL}"/>
    {"".join(guides)}
    <path d="{edge_stroke(light_pts)}" fill="none" stroke="#067a74" stroke-width="2" stroke-dasharray="6 4"/>
    <path d="{edge_stroke(teal_pts)}" fill="none" stroke="#045c58" stroke-width="2.5"/>
    {"".join(frames)}
    {"".join(cuts)}
    {"".join(seams)}
  </g>
  <g transform="translate(24,{TOP + H + 28})" font-family="Segoe UI,sans-serif" font-size="13">
    <rect x="0" y="-10" width="14" height="14" fill="{TEAL}"/>
    <text x="20" y="2" fill="#222">Teal wave-edge (gold seam dots + %)</text>
    <rect x="340" y="-10" width="14" height="14" fill="{LIGHT}"/>
    <text x="360" y="2" fill="#222">Light wave-edge (green seam dots)</text>
    <text x="700" y="2" fill="#555">Each panel = iPhone 16 Pro Max ({SEG_W}×{H})</text>
  </g>
</svg>
"""
    out_dir = Path(__file__).resolve().parent
    out = out_dir / "auth_background_wave_shape.svg"
    out.write_text(svg, encoding="utf-8")
    print(f"Wrote {out}")
    print(f"Teal seams={[round(y * 100) for y in TEAL_SEAMS]}%")
    print("auth_background_wave_shape (finalized ribbon)")


if __name__ == "__main__":
    main()
