# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_08_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "deals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "badge_text"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "deal_type", null: false
    t.uuid "ingredient_id"
    t.integer "multi_quantity"
    t.string "name", null: false
    t.string "publix_item_code"
    t.jsonb "raw_data", default: {}
    t.decimal "sale_price", precision: 8, scale: 2
    t.decimal "savings_amount", precision: 8, scale: 2
    t.uuid "store_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.date "valid_from"
    t.date "valid_until"
    t.index ["category"], name: "index_deals_on_category"
    t.index ["deal_type"], name: "index_deals_on_deal_type"
    t.index ["ingredient_id"], name: "index_deals_on_ingredient_id"
    t.index ["store_id", "publix_item_code"], name: "index_deals_on_store_and_item_code", unique: true, where: "(publix_item_code IS NOT NULL)"
    t.index ["store_id"], name: "index_deals_on_store_id"
    t.index ["valid_until"], name: "index_deals_on_valid_until"
  end

  create_table "ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "average_price", precision: 8, scale: 2
    t.string "barcode"
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "default_unit"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["barcode"], name: "index_ingredients_on_barcode", where: "(barcode IS NOT NULL)"
    t.index ["category"], name: "index_ingredients_on_category"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "meal_plan_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "cooked", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.uuid "meal_plan_id", null: false
    t.string "meal_slot", null: false
    t.uuid "recipe_id"
    t.integer "servings", default: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["cooked"], name: "index_meal_plan_entries_on_cooked"
    t.index ["meal_plan_id", "day_of_week", "meal_slot"], name: "index_meal_plan_entries_on_plan_day_slot", unique: true
    t.index ["meal_plan_id"], name: "index_meal_plan_entries_on_meal_plan_id"
    t.index ["recipe_id"], name: "index_meal_plan_entries_on_recipe_id"
  end

  create_table "meal_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "status", default: "active", null: false
    t.decimal "total_estimated_cost", precision: 8, scale: 2
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.date "week_start_date", null: false
    t.index ["status"], name: "index_meal_plans_on_status"
    t.index ["user_id", "week_start_date"], name: "index_meal_plans_on_user_id_and_week_start_date", unique: true
    t.index ["user_id"], name: "index_meal_plans_on_user_id"
  end

  create_table "recipe_ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "ingredient_id", null: false
    t.string "notes"
    t.decimal "quantity", precision: 8, scale: 3
    t.uuid "recipe_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id"], name: "index_recipe_ingredients_on_recipe_id_and_ingredient_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "calories_per_serving"
    t.integer "cook_time_minutes", default: 20
    t.datetime "created_at", null: false
    t.string "cuisine"
    t.text "description"
    t.string "difficulty", default: "easy"
    t.decimal "estimated_cost", precision: 8, scale: 2
    t.string "external_id"
    t.text "instructions"
    t.boolean "is_dairy_free", default: false, null: false
    t.boolean "is_gluten_free", default: false, null: false
    t.boolean "is_keto", default: false, null: false
    t.boolean "is_vegan", default: false, null: false
    t.boolean "is_vegetarian", default: false, null: false
    t.string "meal_type", null: false
    t.string "name", null: false
    t.integer "prep_time_minutes", default: 10
    t.integer "servings", default: 2, null: false
    t.string "source", default: "seed"
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.index ["difficulty"], name: "index_recipes_on_difficulty"
    t.index ["is_gluten_free"], name: "index_recipes_on_is_gluten_free"
    t.index ["is_vegan"], name: "index_recipes_on_is_vegan"
    t.index ["is_vegetarian"], name: "index_recipes_on_is_vegetarian"
    t.index ["meal_type"], name: "index_recipes_on_meal_type"
    t.index ["name"], name: "index_recipes_on_name"
    t.index ["tags"], name: "index_recipes_on_tags", using: :gin
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shopping_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", default: "pantry", null: false
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.uuid "ingredient_id"
    t.string "name", null: false
    t.text "notes"
    t.integer "position", default: 0, null: false
    t.decimal "quantity", precision: 8, scale: 3
    t.uuid "shopping_list_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_shopping_list_items_on_category"
    t.index ["ingredient_id"], name: "index_shopping_list_items_on_ingredient_id"
    t.index ["shopping_list_id", "checked"], name: "index_shopping_list_items_on_shopping_list_id_and_checked"
    t.index ["shopping_list_id", "position"], name: "index_shopping_list_items_on_shopping_list_id_and_position"
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "meal_plan_id"
    t.string "name", null: false
    t.text "notes"
    t.date "shop_date"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["meal_plan_id"], name: "index_shopping_lists_on_meal_plan_id"
    t.index ["status"], name: "index_shopping_lists_on_status"
    t.index ["user_id", "created_at"], name: "index_shopping_lists_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_shopping_lists_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.string "chain", null: false
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "deals_fetched_at"
    t.string "name", null: false
    t.uuid "parent_store_id"
    t.string "scrape_url"
    t.string "state"
    t.string "store_number"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["chain", "store_number"], name: "index_stores_on_chain_and_store_number", unique: true, where: "(store_number IS NOT NULL)"
    t.index ["chain"], name: "index_stores_on_chain"
    t.index ["parent_store_id"], name: "index_stores_on_parent_store_id"
  end

  create_table "system_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  create_table "user_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "budget_currency", default: "USD"
    t.string "city"
    t.string "cooking_skill", default: "beginner", null: false
    t.datetime "created_at", null: false
    t.datetime "deals_last_seen_at"
    t.string "dietary_restrictions", default: [], array: true
    t.integer "household_size", default: 2, null: false
    t.boolean "include_breakfast", default: true, null: false
    t.boolean "include_dinner", default: true, null: false
    t.boolean "include_lunch", default: true, null: false
    t.string "meal_complexity", default: "moderate"
    t.integer "meals_per_week", default: 7, null: false
    t.string "preferred_cuisines", default: [], array: true
    t.string "preferred_store"
    t.string "state"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.decimal "weekly_budget", precision: 8, scale: 2
    t.string "zip_code"
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
    t.index ["zip_code"], name: "index_user_preferences_on_zip_code"
  end

  create_table "user_stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "primary", default: false, null: false
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["store_id"], name: "index_user_stores_on_store_id"
    t.index ["user_id", "store_id"], name: "index_user_stores_on_user_id_and_store_id", unique: true
    t.index ["user_id"], name: "index_user_stores_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email_address", null: false
    t.boolean "onboarding_complete", default: false, null: false
    t.string "onboarding_step", default: "preferences", null: false
    t.string "password_digest", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
  end

  add_foreign_key "deals", "ingredients"
  add_foreign_key "deals", "stores"
  add_foreign_key "meal_plan_entries", "meal_plans"
  add_foreign_key "meal_plan_entries", "recipes"
  add_foreign_key "meal_plans", "users"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "sessions", "users"
  add_foreign_key "shopping_list_items", "ingredients"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "meal_plans"
  add_foreign_key "shopping_lists", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "stores", "stores", column: "parent_store_id"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "user_stores", "stores"
  add_foreign_key "user_stores", "users"
end
