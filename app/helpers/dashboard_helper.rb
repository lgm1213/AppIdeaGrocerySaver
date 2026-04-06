module DashboardHelper
  BudgetRing = Data.define(:pct, :dash_len, :gap_len, :ring_color, :spent, :budget)

  def budget_ring_data(budget_raw, spent_raw)
    budget = budget_raw.to_f
    spent  = spent_raw.to_f
    pct    = budget > 0 ? [ (spent / budget * 100).round, 100 ].min : 0

    r      = 40
    circ   = (2 * Math::PI * r).round(2)

    BudgetRing.new(
      pct:        pct,
      dash_len:   (circ * pct / 100.0).round(2),
      gap_len:    (circ - circ * pct / 100.0).round(2),
      ring_color: pct >= 100 ? "#c0392b" : pct >= 80 ? "#e67e22" : "#1a7425",
      spent:      spent,
      budget:     budget
    )
  end
end
