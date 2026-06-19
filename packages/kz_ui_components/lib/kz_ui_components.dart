/// kz_ui_components — Atomic Design System.
///
/// ATOMS    → átomos indivisibles (TierBadge, CyberButton)
/// MOLECULES → combinaciones de átomos (RayitaInput, KanaDisplay, GridCell, MetricChip)
/// ORGANISMS → secciones complejas de UI (GameHeader, InventorySection, ActivityGraph)
/// PAINTERS  → CustomPainters puros (BgPatternPainter, ActivityGraphPainter)
library kz_ui_components;

// ─── Atoms ───────────────────────────────────────────────────────────────────
export 'src/atoms/tier_badge.dart';
export 'src/atoms/cyber_button.dart';

// ─── Molecules ────────────────────────────────────────────────────────────────
export 'src/molecules/rayita_input.dart';
export 'src/molecules/kana_display.dart';
export 'src/molecules/grid_cell.dart';
export 'src/molecules/metric_chip.dart';

// ─── Organisms ────────────────────────────────────────────────────────────────
export 'src/organisms/game_header.dart';
export 'src/organisms/activity_graph.dart';
export 'src/organisms/inventory_section.dart';
export 'src/organisms/cyber_zen_modal.dart';

// ─── Painters ────────────────────────────────────────────────────────────────
export 'src/painters/bg_pattern_painter.dart';
export 'src/painters/activity_graph_painter.dart';
