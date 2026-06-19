/// kz_ui_components — Atomic Design System.
///
/// ATOMS    → átomos indivisibles (TierBadge, CyberButton)
/// MOLECULES → combinaciones de átomos (RayitaInput, KanaDisplay, GridCell, MetricChip)
/// ORGANISMS → secciones complejas de UI (GameHeader, InventorySection, ActivityGraph)
/// PAINTERS  → CustomPainters puros (BgPatternPainter, ActivityGraphPainter)
library;

// ─── Atoms ───────────────────────────────────────────────────────────────────
export 'src/atoms/tier_badge.dart';
export 'src/atoms/cyber_button.dart';
export 'src/atoms/kanji_vg_painter.dart';

// ─── Molecules ────────────────────────────────────────────────────────────────
export 'src/molecules/rayita_input.dart';
export 'src/molecules/kana_display.dart';
export 'src/molecules/grid_cell.dart';
export 'src/molecules/kanji_grid_cell.dart';
export 'src/molecules/metric_chip.dart';

// ─── Organisms ────────────────────────────────────────────────────────────────
export 'src/organisms/game_header.dart';
export 'src/organisms/activity_graph.dart';
export 'src/organisms/elastic_matrix.dart';
export 'src/organisms/inventory_section.dart';
export 'src/organisms/cyber_zen_modal.dart';
export 'src/organisms/kanji_detail_modal.dart';
export 'src/organisms/settings_modal.dart';

// ─── Painters ────────────────────────────────────────────────────────────────
export 'src/painters/bg_pattern_painter.dart';
export 'src/painters/activity_graph_painter.dart';
export 'src/painters/kanji_vector_painter.dart';
