/// Costs shared by the simulation and the interface, so changing a price in one
/// place cannot leave the two disagreeing.
class GameBalance {
  const GameBalance._();

  /// Credits one manual feed costs. Zero credits is the free emergency feed;
  /// between 1 and this value feeding is refused.
  static const double feedCostCredits = 5.0;

  /// DNA one animal revival costs.
  static const double reviveCostDna = 15.0;
}
