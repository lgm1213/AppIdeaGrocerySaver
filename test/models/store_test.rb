require "test_helper"

class StoreTest < ActiveSupport::TestCase
  # ── Validations ────────────────────────────────────────────────────────────

  test "valid with required attributes" do
    store = build(:store)
    assert store.valid?
  end

  test "invalid without name" do
    store = build(:store, name: nil)
    assert store.invalid?
    assert store.errors[:name].any?
  end

  test "invalid without chain" do
    store = build(:store, chain: nil)
    assert store.invalid?
    assert store.errors[:chain].any?
  end

  test "invalid with unrecognized chain" do
    store = build(:store, chain: "whole_foods")
    assert store.invalid?
    assert store.errors[:chain].any?
  end

  test "valid for each supported chain" do
    Store::CHAINS.each do |chain|
      store = build(:store, chain: chain)
      assert store.valid?, "Expected store with chain '#{chain}' to be valid"
    end
  end

  # ── deals_stale? ──────────────────────────────────────────────────────────

  test "deals_stale? returns true when deals_fetched_at is nil" do
    store = build(:store, deals_fetched_at: nil)
    assert store.deals_stale?
  end

  test "deals_stale? returns true when deals_fetched_at is over a day ago" do
    store = build(:store, deals_fetched_at: 2.days.ago)
    assert store.deals_stale?
  end

  test "deals_stale? returns false when deals_fetched_at is recent" do
    store = build(:store, deals_fetched_at: 1.hour.ago)
    assert_not store.deals_stale?
  end
end
