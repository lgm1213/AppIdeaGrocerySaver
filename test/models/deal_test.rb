require "test_helper"

class DealTest < ActiveSupport::TestCase
  # ── Validations ────────────────────────────────────────────────────────────

  test "valid with required attributes" do
    deal = build(:deal)
    assert deal.valid?
  end

  test "invalid without name" do
    deal = build(:deal, name: nil)
    assert deal.invalid?
    assert deal.errors[:name].any?
  end

  test "invalid without deal_type" do
    deal = build(:deal, deal_type: nil)
    assert deal.invalid?
    assert deal.errors[:deal_type].any?
  end

  test "invalid with unknown deal_type" do
    deal = build(:deal, deal_type: "clearance")
    assert deal.invalid?
  end

  # ── active scope ───────────────────────────────────────────────────────────

  test "active scope includes deal with future valid_until" do
    deal = create(:deal, valid_until: 7.days.from_now.to_date)
    assert_includes Deal.active, deal
  end

  test "active scope includes deal with nil valid_until" do
    deal = create(:deal, :no_expiry)
    assert_includes Deal.active, deal
  end

  test "active scope excludes deal with past valid_until" do
    deal = create(:deal, :expired)
    assert_not_includes Deal.active, deal
  end

  # ── matched / unmatched scopes ────────────────────────────────────────────

  test "matched scope returns only deals with ingredient" do
    matched   = create(:deal, :matched)
    unmatched = create(:deal)

    result = Deal.matched
    assert_includes result, matched
    assert_not_includes result, unmatched
  end

  test "unmatched scope returns only deals without ingredient" do
    matched   = create(:deal, :matched)
    unmatched = create(:deal)

    result = Deal.unmatched
    assert_includes result, unmatched
    assert_not_includes result, matched
  end

  # ── savings_label ─────────────────────────────────────────────────────────

  test "savings_label for bogo deal" do
    deal = build(:deal, :bogo)
    assert_equal "Buy 1 Get 1 Free", deal.savings_label
  end

  test "savings_label for multi deal" do
    deal = build(:deal, :multi, multi_quantity: 3, sale_price: 6.00)
    assert_equal "3 for $6.00", deal.savings_label
  end

  test "savings_label for sale deal with unit" do
    deal = build(:deal, deal_type: "sale", sale_price: 2.49, unit: "lb")
    assert_equal "$2.49/lb", deal.savings_label
  end

  test "savings_label for sale deal without unit" do
    deal = build(:deal, deal_type: "sale", sale_price: 3.99, unit: nil)
    assert_equal "$3.99", deal.savings_label
  end

  # ── active? instance method ───────────────────────────────────────────────

  test "active? returns true when valid_until is in the future" do
    deal = build(:deal, valid_until: 1.day.from_now.to_date)
    assert deal.active?
  end

  test "active? returns true when valid_until is nil" do
    deal = build(:deal, :no_expiry)
    assert deal.active?
  end

  test "active? returns false when valid_until is in the past" do
    deal = build(:deal, :expired)
    assert_not deal.active?
  end
end
