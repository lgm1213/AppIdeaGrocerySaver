# frozen_string_literal: true

# ─────────────────────────────────────────────────────────────────────────────
# Seeds — Save & Savor
# Run with: rails db:seed
# Re-runnable (find_or_create_by! everywhere)
# ─────────────────────────────────────────────────────────────────────────────

puts "🌱  Seeding ingredients…"

ingredients_data = [
  # Produce
  { name: "Avocado",           category: "produce",   default_unit: "each",  average_price: 1.29 },
  { name: "Baby Spinach",      category: "produce",   default_unit: "oz",    average_price: 0.25 },
  { name: "Bell Pepper",       category: "produce",   default_unit: "each",  average_price: 0.99 },
  { name: "Broccoli",          category: "produce",   default_unit: "head",  average_price: 1.79 },
  { name: "Cherry Tomatoes",   category: "produce",   default_unit: "cup",   average_price: 0.75 },
  { name: "Garlic",            category: "produce",   default_unit: "clove", average_price: 0.10 },
  { name: "Lemon",             category: "produce",   default_unit: "each",  average_price: 0.59 },
  { name: "Onion",             category: "produce",   default_unit: "each",  average_price: 0.49 },
  { name: "Sweet Potato",      category: "produce",   default_unit: "each",  average_price: 0.89 },
  { name: "Zucchini",          category: "produce",   default_unit: "each",  average_price: 0.79 },
  { name: "Banana",            category: "produce",   default_unit: "each",  average_price: 0.25 },
  { name: "Blueberries",       category: "produce",   default_unit: "cup",   average_price: 1.50 },
  { name: "Kale",              category: "produce",   default_unit: "cup",   average_price: 0.40 },

  # Dairy
  { name: "Cheddar Cheese",    category: "dairy",     default_unit: "oz",    average_price: 0.50 },
  { name: "Eggs",              category: "dairy",     default_unit: "each",  average_price: 0.30 },
  { name: "Greek Yogurt",      category: "dairy",     default_unit: "cup",   average_price: 1.20 },
  { name: "Milk",              category: "dairy",     default_unit: "cup",   average_price: 0.30 },
  { name: "Parmesan",          category: "dairy",     default_unit: "oz",    average_price: 0.60 },
  { name: "Butter",            category: "dairy",     default_unit: "tbsp",  average_price: 0.20 },

  # Meat
  { name: "Chicken Breast",    category: "meat",      default_unit: "lb",    average_price: 3.49 },
  { name: "Ground Beef",       category: "meat",      default_unit: "lb",    average_price: 4.99 },
  { name: "Ground Turkey",     category: "meat",      default_unit: "lb",    average_price: 3.99 },
  { name: "Bacon",             category: "meat",      default_unit: "slice", average_price: 0.45 },

  # Seafood
  { name: "Salmon Fillet",     category: "seafood",   default_unit: "lb",    average_price: 8.99 },
  { name: "Shrimp",            category: "seafood",   default_unit: "lb",    average_price: 7.99 },
  { name: "Tuna (Canned)",     category: "seafood",   default_unit: "can",   average_price: 1.29 },

  # Pantry
  { name: "Black Beans",       category: "pantry",    default_unit: "cup",   average_price: 0.40 },
  { name: "Brown Rice",        category: "pantry",    default_unit: "cup",   average_price: 0.30 },
  { name: "Chickpeas",         category: "pantry",    default_unit: "cup",   average_price: 0.50 },
  { name: "Coconut Milk",      category: "pantry",    default_unit: "can",   average_price: 1.79 },
  { name: "Diced Tomatoes",    category: "pantry",    default_unit: "can",   average_price: 0.99 },
  { name: "Olive Oil",         category: "pantry",    default_unit: "tbsp",  average_price: 0.15 },
  { name: "Pasta",             category: "pantry",    default_unit: "oz",    average_price: 0.20 },
  { name: "Quinoa",            category: "pantry",    default_unit: "cup",   average_price: 0.80 },
  { name: "Rolled Oats",       category: "pantry",    default_unit: "cup",   average_price: 0.25 },
  { name: "Soy Sauce",         category: "pantry",    default_unit: "tbsp",  average_price: 0.10 },
  { name: "Vegetable Broth",   category: "pantry",    default_unit: "cup",   average_price: 0.35 },

  # Bakery
  { name: "Whole Wheat Bread", category: "bakery",    default_unit: "slice", average_price: 0.30 },
  { name: "Tortillas",         category: "bakery",    default_unit: "each",  average_price: 0.25 }
]

ingredients_data.each do |attrs|
  Ingredient.find_or_create_by!(name: attrs[:name].strip.titleize) do |i|
    i.category      = attrs[:category]
    i.default_unit  = attrs[:default_unit]
    i.average_price = attrs[:average_price]
  end
end

puts "  → #{Ingredient.count} ingredients"

# ─────────────────────────────────────────────────────────────────────────────
puts "🍳  Seeding recipes…"

recipes_data = [
  # ── BREAKFAST ──────────────────────────────────────────────────────────────
  {
    name: "Overnight Oats with Blueberries",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 0, servings: 2,
    estimated_cost: 3.50, calories_per_serving: 320,
    is_vegetarian: true, is_vegan: true, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Creamy make-ahead oats topped with fresh blueberries.",
    instructions: "Combine oats, milk, and yogurt. Refrigerate overnight. Top with blueberries.",
    tags: %w[meal-prep quick make-ahead],
    source: "seed"
  },
  {
    name: "Avocado Toast with Poached Egg",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 10, servings: 2,
    estimated_cost: 5.00, calories_per_serving: 380,
    is_vegetarian: true, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Creamy avocado on whole grain toast with a perfect poached egg.",
    instructions: "Toast bread. Mash avocado with lemon, salt. Poach eggs 3 min. Assemble.",
    tags: %w[brunch protein],
    source: "seed"
  },
  {
    name: "Greek Yogurt Parfait",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 0, servings: 1,
    estimated_cost: 3.00, calories_per_serving: 290,
    is_vegetarian: true, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: false,
    description: "Layered yogurt with granola and fresh fruit.",
    instructions: "Layer yogurt, granola, and blueberries in a glass. Repeat.",
    tags: %w[quick no-cook],
    source: "seed"
  },
  {
    name: "Veggie Scrambled Eggs",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 10, servings: 2,
    estimated_cost: 4.50, calories_per_serving: 310,
    is_vegetarian: true, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: true,
    description: "Fluffy eggs scrambled with bell peppers, spinach, and onion.",
    instructions: "Sauté veggies in butter. Whisk eggs, pour in. Fold gently until just set.",
    tags: %w[protein low-carb keto],
    source: "seed"
  },
  {
    name: "Banana Oat Pancakes",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 15, servings: 2,
    estimated_cost: 3.20, calories_per_serving: 350,
    is_vegetarian: true, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: false,
    description: "Two-ingredient pancakes made with banana and rolled oats.",
    instructions: "Blend banana and oats. Cook on griddle 2 min per side.",
    tags: %w[gluten-free simple],
    source: "seed"
  },
  {
    name: "Smoothie Bowl",
    meal_type: "breakfast", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 0, servings: 1,
    estimated_cost: 4.00, calories_per_serving: 280,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Thick blended smoothie base topped with fresh fruit and granola.",
    instructions: "Blend banana, blueberries, and oat milk thick. Pour into bowl, add toppings.",
    tags: %w[vegan no-cook colorful],
    source: "seed"
  },

  # ── LUNCH ─────────────────────────────────────────────────────────────────
  {
    name: "Chicken Caesar Salad",
    meal_type: "lunch", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 15, servings: 2,
    estimated_cost: 8.00, calories_per_serving: 420,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: true,
    description: "Grilled chicken over romaine with parmesan and creamy Caesar dressing.",
    instructions: "Season and grill chicken. Toss kale with dressing and parmesan. Slice chicken on top.",
    tags: %w[protein salad keto],
    source: "seed"
  },
  {
    name: "Black Bean Burrito Bowl",
    meal_type: "lunch", difficulty: "easy", cuisine: "mexican",
    prep_time_minutes: 10, cook_time_minutes: 20, servings: 2,
    estimated_cost: 5.50, calories_per_serving: 510,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Spiced black beans over brown rice with avocado and salsa.",
    instructions: "Cook rice. Season beans with cumin, garlic. Assemble bowls with avocado.",
    tags: %w[vegan meal-prep budget],
    source: "seed"
  },
  {
    name: "Tuna Salad Sandwich",
    meal_type: "lunch", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 0, servings: 2,
    estimated_cost: 4.50, calories_per_serving: 380,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Classic tuna salad with celery and light mayo on whole wheat.",
    instructions: "Mix tuna, mayo, celery, lemon. Season with salt and pepper. Serve on bread.",
    tags: %w[quick no-cook budget],
    source: "seed"
  },
  {
    name: "Quinoa Power Bowl",
    meal_type: "lunch", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 20, servings: 2,
    estimated_cost: 7.00, calories_per_serving: 460,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Hearty quinoa bowl with roasted sweet potato, chickpeas, and kale.",
    instructions: "Cook quinoa. Roast sweet potato and chickpeas at 400°F 25 min. Sauté kale. Assemble.",
    tags: %w[vegan meal-prep high-protein],
    source: "seed"
  },
  {
    name: "Shrimp Tacos",
    meal_type: "lunch", difficulty: "medium", cuisine: "mexican",
    prep_time_minutes: 15, cook_time_minutes: 10, servings: 2,
    estimated_cost: 9.00, calories_per_serving: 490,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Seasoned sautéed shrimp in flour tortillas with avocado slaw.",
    instructions: "Season shrimp with cumin and paprika. Sauté 3 min. Serve in tortillas with avocado.",
    tags: %w[seafood quick],
    source: "seed"
  },
  {
    name: "Lentil Soup",
    meal_type: "lunch", difficulty: "easy", cuisine: "mediterranean",
    prep_time_minutes: 10, cook_time_minutes: 30, servings: 4,
    estimated_cost: 4.00, calories_per_serving: 320,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Warming red lentil soup with cumin, tomatoes, and lemon.",
    instructions: "Sauté onion and garlic. Add lentils, broth, tomatoes. Simmer 25 min. Season.",
    tags: %w[vegan batch-cook budget],
    source: "seed"
  },
  {
    name: "Caprese Salad",
    meal_type: "lunch", difficulty: "easy", cuisine: "italian",
    prep_time_minutes: 10, cook_time_minutes: 0, servings: 2,
    estimated_cost: 6.50, calories_per_serving: 290,
    is_vegetarian: true, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: true,
    description: "Fresh tomatoes and mozzarella drizzled with olive oil and basil.",
    instructions: "Slice tomatoes and mozzarella. Alternate with basil. Drizzle olive oil and balsamic.",
    tags: %w[no-cook keto italian],
    source: "seed"
  },
  {
    name: "Turkey Lettuce Wraps",
    meal_type: "lunch", difficulty: "easy", cuisine: "asian",
    prep_time_minutes: 10, cook_time_minutes: 15, servings: 2,
    estimated_cost: 6.00, calories_per_serving: 340,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: true, is_keto: true,
    description: "Seasoned ground turkey in crisp lettuce cups with a ginger soy sauce.",
    instructions: "Cook turkey with garlic, ginger, soy sauce. Serve in lettuce leaves.",
    tags: %w[low-carb keto protein],
    source: "seed"
  },

  # ── DINNER ────────────────────────────────────────────────────────────────
  {
    name: "Garlic Butter Salmon",
    meal_type: "dinner", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 15, servings: 2,
    estimated_cost: 14.00, calories_per_serving: 480,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: false, is_keto: true,
    description: "Pan-seared salmon with garlic lemon butter sauce.",
    instructions: "Pat salmon dry. Sear skin-down 6 min. Flip, add butter and garlic. Baste 3 min.",
    tags: %w[seafood keto quick],
    source: "seed"
  },
  {
    name: "Chicken Stir-Fry",
    meal_type: "dinner", difficulty: "medium", cuisine: "asian",
    prep_time_minutes: 15, cook_time_minutes: 15, servings: 4,
    estimated_cost: 10.00, calories_per_serving: 390,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Crispy chicken with broccoli, bell peppers, and ginger soy sauce.",
    instructions: "Marinate chicken in soy sauce. Stir-fry on high heat. Add veggies, toss. Serve over rice.",
    tags: %w[asian quick],
    source: "seed"
  },
  {
    name: "Beef Tacos",
    meal_type: "dinner", difficulty: "easy", cuisine: "mexican",
    prep_time_minutes: 10, cook_time_minutes: 15, servings: 4,
    estimated_cost: 12.00, calories_per_serving: 520,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: false, is_keto: false,
    description: "Seasoned ground beef in crispy taco shells with all the fixings.",
    instructions: "Brown beef, season with cumin and chili powder. Serve in tortillas with toppings.",
    tags: %w[family-friendly crowd-pleaser],
    source: "seed"
  },
  {
    name: "Spaghetti Bolognese",
    meal_type: "dinner", difficulty: "medium", cuisine: "italian",
    prep_time_minutes: 10, cook_time_minutes: 40, servings: 4,
    estimated_cost: 11.00, calories_per_serving: 580,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Rich meat sauce slow-cooked with tomatoes over al dente pasta.",
    instructions: "Brown beef, add onion and garlic. Pour in tomatoes and broth. Simmer 30 min. Toss with pasta.",
    tags: %w[italian comfort],
    source: "seed"
  },
  {
    name: "Vegetable Curry",
    meal_type: "dinner", difficulty: "medium", cuisine: "indian",
    prep_time_minutes: 15, cook_time_minutes: 25, servings: 4,
    estimated_cost: 7.00, calories_per_serving: 380,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Aromatic coconut milk curry loaded with sweet potato and chickpeas.",
    instructions: "Sauté onion, garlic, ginger. Add curry paste. Pour in coconut milk. Add veg, simmer 20 min.",
    tags: %w[vegan indian comfort],
    source: "seed"
  },
  {
    name: "Baked Lemon Herb Chicken",
    meal_type: "dinner", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 35, servings: 4,
    estimated_cost: 10.00, calories_per_serving: 360,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: true, is_keto: true,
    description: "Juicy oven-baked chicken breasts with lemon, garlic, and herbs.",
    instructions: "Marinate chicken in lemon juice, olive oil, garlic, and herbs. Bake 400°F 30 min.",
    tags: %w[keto meal-prep gluten-free],
    source: "seed"
  },
  {
    name: "Shrimp Fried Rice",
    meal_type: "dinner", difficulty: "medium", cuisine: "asian",
    prep_time_minutes: 10, cook_time_minutes: 20, servings: 4,
    estimated_cost: 11.00, calories_per_serving: 450,
    is_vegetarian: false, is_vegan: false, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Classic takeout-style fried rice with shrimp, egg, and vegetables.",
    instructions: "Cook rice and cool. Stir-fry shrimp, remove. Fry egg in same pan, add rice and veg.",
    tags: %w[asian quick],
    source: "seed"
  },
  {
    name: "Roasted Veggie Pasta",
    meal_type: "dinner", difficulty: "easy", cuisine: "italian",
    prep_time_minutes: 10, cook_time_minutes: 30, servings: 4,
    estimated_cost: 6.50, calories_per_serving: 420,
    is_vegetarian: true, is_vegan: true, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Pasta tossed with oven-roasted zucchini, cherry tomatoes, and garlic.",
    instructions: "Roast zucchini and tomatoes with olive oil at 425°F 20 min. Cook pasta, toss together.",
    tags: %w[vegan italian batch-cook],
    source: "seed"
  },
  {
    name: "Turkey Meatball Soup",
    meal_type: "dinner", difficulty: "medium", cuisine: "american",
    prep_time_minutes: 20, cook_time_minutes: 30, servings: 4,
    estimated_cost: 9.00, calories_per_serving: 340,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Tender turkey meatballs in a hearty vegetable broth with spinach.",
    instructions: "Form turkey meatballs. Brown in pot. Add broth, tomatoes, spinach. Simmer 20 min.",
    tags: %w[comfort meal-prep],
    source: "seed"
  },
  {
    name: "Sweet Potato Black Bean Tacos",
    meal_type: "dinner", difficulty: "easy", cuisine: "mexican",
    prep_time_minutes: 10, cook_time_minutes: 25, servings: 4,
    estimated_cost: 6.00, calories_per_serving: 400,
    is_vegetarian: true, is_vegan: true, is_gluten_free: false, is_dairy_free: true, is_keto: false,
    description: "Roasted sweet potato and smoky black beans in corn tortillas.",
    instructions: "Cube and roast sweet potato. Warm beans with cumin. Serve in tortillas with avocado.",
    tags: %w[vegan mexican budget],
    source: "seed"
  },
  {
    name: "Salmon with Roasted Broccoli",
    meal_type: "dinner", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 5, cook_time_minutes: 25, servings: 2,
    estimated_cost: 15.00, calories_per_serving: 500,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: true, is_keto: true,
    description: "Sheet-pan salmon and crispy roasted broccoli with lemon dressing.",
    instructions: "Place salmon and broccoli on sheet pan. Drizzle olive oil. Roast 400°F 20 min.",
    tags: %w[keto seafood sheet-pan],
    source: "seed"
  },
  {
    name: "Chickpea Tikka Masala",
    meal_type: "dinner", difficulty: "medium", cuisine: "indian",
    prep_time_minutes: 10, cook_time_minutes: 25, servings: 4,
    estimated_cost: 6.00, calories_per_serving: 390,
    is_vegetarian: true, is_vegan: true, is_gluten_free: true, is_dairy_free: true, is_keto: false,
    description: "Creamy tomato-based tikka sauce with tender chickpeas.",
    instructions: "Sauté onion and spices. Add tomatoes, coconut milk, chickpeas. Simmer 20 min.",
    tags: %w[vegan indian comfort budget],
    source: "seed"
  },
  {
    name: "Ground Turkey Zucchini Skillet",
    meal_type: "dinner", difficulty: "easy", cuisine: "american",
    prep_time_minutes: 10, cook_time_minutes: 20, servings: 4,
    estimated_cost: 8.50, calories_per_serving: 340,
    is_vegetarian: false, is_vegan: false, is_gluten_free: true, is_dairy_free: true, is_keto: true,
    description: "One-pan lean ground turkey with zucchini, tomatoes, and Italian seasoning.",
    instructions: "Brown turkey. Add garlic, onion, zucchini, tomatoes. Season, simmer 10 min.",
    tags: %w[one-pan keto low-carb quick],
    source: "seed"
  }
]

recipes_data.each do |attrs|
  Recipe.find_or_create_by!(name: attrs[:name]) do |r|
    r.assign_attributes(attrs)
  end
end

puts "  → #{Recipe.count} recipes"

# ─────────────────────────────────────────────────────────────────────────────
puts "🔗  Seeding recipe ingredients…"

# Helper: find by name (normalizes via model)
def ing(name) = Ingredient.find_by!(name: name.strip.titleize)
def recipe(name) = Recipe.find_by!(name: name)

recipe_ingredients_data = {
  # ── BREAKFAST ──────────────────────────────────────────────────────────────
  "Overnight Oats with Blueberries" => [
    { ingredient: "Rolled Oats",   quantity: 1,    unit: "cup" },
    { ingredient: "Milk",          quantity: 0.5,  unit: "cup" },
    { ingredient: "Greek Yogurt",  quantity: 0.5,  unit: "cup" },
    { ingredient: "Blueberries",   quantity: 0.5,  unit: "cup" }
  ],
  "Avocado Toast with Poached Egg" => [
    { ingredient: "Whole Wheat Bread", quantity: 2, unit: "slice" },
    { ingredient: "Avocado",           quantity: 1, unit: "each" },
    { ingredient: "Eggs",              quantity: 2, unit: "each" },
    { ingredient: "Lemon",             quantity: 0.5, unit: "each" }
  ],
  "Greek Yogurt Parfait" => [
    { ingredient: "Greek Yogurt",  quantity: 1,   unit: "cup" },
    { ingredient: "Blueberries",   quantity: 0.5, unit: "cup" },
    { ingredient: "Rolled Oats",   quantity: 0.25, unit: "cup" }
  ],
  "Veggie Scrambled Eggs" => [
    { ingredient: "Eggs",         quantity: 4,   unit: "each" },
    { ingredient: "Bell Pepper",  quantity: 1,   unit: "each" },
    { ingredient: "Baby Spinach", quantity: 1,   unit: "cup" },
    { ingredient: "Onion",        quantity: 0.5, unit: "each" },
    { ingredient: "Butter",       quantity: 1,   unit: "tbsp" }
  ],
  "Banana Oat Pancakes" => [
    { ingredient: "Banana",      quantity: 2,   unit: "each" },
    { ingredient: "Rolled Oats", quantity: 1,   unit: "cup" },
    { ingredient: "Eggs",        quantity: 2,   unit: "each" },
    { ingredient: "Milk",        quantity: 0.25, unit: "cup" }
  ],
  "Smoothie Bowl" => [
    { ingredient: "Banana",      quantity: 1,   unit: "each" },
    { ingredient: "Blueberries", quantity: 1,   unit: "cup" },
    { ingredient: "Rolled Oats", quantity: 0.25, unit: "cup" },
    { ingredient: "Milk",        quantity: 0.5, unit: "cup" }
  ],

  # ── LUNCH ─────────────────────────────────────────────────────────────────
  "Chicken Caesar Salad" => [
    { ingredient: "Chicken Breast", quantity: 0.5, unit: "lb" },
    { ingredient: "Kale",           quantity: 3,   unit: "cup" },
    { ingredient: "Parmesan",       quantity: 1,   unit: "oz" },
    { ingredient: "Lemon",          quantity: 0.5, unit: "each" },
    { ingredient: "Olive Oil",      quantity: 2,   unit: "tbsp" }
  ],
  "Black Bean Burrito Bowl" => [
    { ingredient: "Black Beans",  quantity: 1,   unit: "cup" },
    { ingredient: "Brown Rice",   quantity: 0.5, unit: "cup" },
    { ingredient: "Avocado",      quantity: 1,   unit: "each" },
    { ingredient: "Onion",        quantity: 0.5, unit: "each" },
    { ingredient: "Garlic",       quantity: 2,   unit: "clove" },
    { ingredient: "Olive Oil",    quantity: 1,   unit: "tbsp" }
  ],
  "Tuna Salad Sandwich" => [
    { ingredient: "Tuna (Canned)",     quantity: 2,   unit: "can" },
    { ingredient: "Whole Wheat Bread", quantity: 4,   unit: "slice" },
    { ingredient: "Lemon",             quantity: 0.5, unit: "each" }
  ],
  "Quinoa Power Bowl" => [
    { ingredient: "Quinoa",      quantity: 0.5, unit: "cup" },
    { ingredient: "Sweet Potato", quantity: 1,  unit: "each" },
    { ingredient: "Chickpeas",   quantity: 0.5, unit: "cup" },
    { ingredient: "Kale",        quantity: 2,   unit: "cup" },
    { ingredient: "Olive Oil",   quantity: 2,   unit: "tbsp" }
  ],
  "Shrimp Tacos" => [
    { ingredient: "Shrimp",    quantity: 0.5, unit: "lb" },
    { ingredient: "Tortillas", quantity: 4,   unit: "each" },
    { ingredient: "Avocado",   quantity: 1,   unit: "each" },
    { ingredient: "Lemon",     quantity: 1,   unit: "each" },
    { ingredient: "Olive Oil", quantity: 1,   unit: "tbsp" }
  ],
  "Lentil Soup" => [
    { ingredient: "Chickpeas",       quantity: 1,   unit: "cup" },
    { ingredient: "Vegetable Broth", quantity: 3,   unit: "cup" },
    { ingredient: "Onion",           quantity: 1,   unit: "each" },
    { ingredient: "Garlic",          quantity: 3,   unit: "clove" },
    { ingredient: "Diced Tomatoes",  quantity: 1,   unit: "can" },
    { ingredient: "Lemon",           quantity: 1,   unit: "each" },
    { ingredient: "Olive Oil",       quantity: 1,   unit: "tbsp" }
  ],
  "Caprese Salad" => [
    { ingredient: "Cherry Tomatoes", quantity: 2,   unit: "cup" },
    { ingredient: "Parmesan",        quantity: 2,   unit: "oz" },
    { ingredient: "Olive Oil",       quantity: 2,   unit: "tbsp" },
    { ingredient: "Lemon",           quantity: 0.5, unit: "each" }
  ],
  "Turkey Lettuce Wraps" => [
    { ingredient: "Ground Turkey", quantity: 0.5, unit: "lb" },
    { ingredient: "Garlic",        quantity: 2,   unit: "clove" },
    { ingredient: "Soy Sauce",     quantity: 2,   unit: "tbsp" },
    { ingredient: "Baby Spinach",  quantity: 1,   unit: "cup" }
  ],

  # ── DINNER ────────────────────────────────────────────────────────────────
  "Garlic Butter Salmon" => [
    { ingredient: "Salmon Fillet", quantity: 0.75, unit: "lb" },
    { ingredient: "Butter",        quantity: 2,    unit: "tbsp" },
    { ingredient: "Garlic",        quantity: 3,    unit: "clove" },
    { ingredient: "Lemon",         quantity: 1,    unit: "each" }
  ],
  "Chicken Stir-Fry" => [
    { ingredient: "Chicken Breast", quantity: 1,   unit: "lb" },
    { ingredient: "Broccoli",       quantity: 1,   unit: "head" },
    { ingredient: "Bell Pepper",    quantity: 1,   unit: "each" },
    { ingredient: "Soy Sauce",      quantity: 3,   unit: "tbsp" },
    { ingredient: "Brown Rice",     quantity: 1,   unit: "cup" },
    { ingredient: "Garlic",         quantity: 3,   unit: "clove" },
    { ingredient: "Olive Oil",      quantity: 2,   unit: "tbsp" }
  ],
  "Beef Tacos" => [
    { ingredient: "Ground Beef", quantity: 1, unit: "lb" },
    { ingredient: "Tortillas",   quantity: 8, unit: "each" },
    { ingredient: "Onion",       quantity: 1, unit: "each" },
    { ingredient: "Garlic",      quantity: 2, unit: "clove" }
  ],
  "Spaghetti Bolognese" => [
    { ingredient: "Ground Beef",     quantity: 1,   unit: "lb" },
    { ingredient: "Pasta",           quantity: 12,  unit: "oz" },
    { ingredient: "Onion",           quantity: 1,   unit: "each" },
    { ingredient: "Garlic",          quantity: 3,   unit: "clove" },
    { ingredient: "Diced Tomatoes",  quantity: 1,   unit: "can" },
    { ingredient: "Vegetable Broth", quantity: 0.5, unit: "cup" },
    { ingredient: "Olive Oil",       quantity: 2,   unit: "tbsp" }
  ],
  "Vegetable Curry" => [
    { ingredient: "Sweet Potato",   quantity: 2,   unit: "each" },
    { ingredient: "Chickpeas",      quantity: 1,   unit: "cup" },
    { ingredient: "Coconut Milk",   quantity: 1,   unit: "can" },
    { ingredient: "Onion",          quantity: 1,   unit: "each" },
    { ingredient: "Garlic",         quantity: 3,   unit: "clove" },
    { ingredient: "Diced Tomatoes", quantity: 1,   unit: "can" },
    { ingredient: "Olive Oil",      quantity: 2,   unit: "tbsp" }
  ],
  "Baked Lemon Herb Chicken" => [
    { ingredient: "Chicken Breast", quantity: 1,   unit: "lb" },
    { ingredient: "Lemon",          quantity: 2,   unit: "each" },
    { ingredient: "Garlic",         quantity: 4,   unit: "clove" },
    { ingredient: "Olive Oil",      quantity: 2,   unit: "tbsp" }
  ],
  "Shrimp Fried Rice" => [
    { ingredient: "Shrimp",     quantity: 0.75, unit: "lb" },
    { ingredient: "Brown Rice", quantity: 1,    unit: "cup" },
    { ingredient: "Eggs",       quantity: 2,    unit: "each" },
    { ingredient: "Soy Sauce",  quantity: 3,    unit: "tbsp" },
    { ingredient: "Garlic",     quantity: 2,    unit: "clove" },
    { ingredient: "Olive Oil",  quantity: 2,    unit: "tbsp" }
  ],
  "Roasted Veggie Pasta" => [
    { ingredient: "Pasta",           quantity: 12, unit: "oz" },
    { ingredient: "Zucchini",        quantity: 2,  unit: "each" },
    { ingredient: "Cherry Tomatoes", quantity: 1,  unit: "cup" },
    { ingredient: "Garlic",          quantity: 4,  unit: "clove" },
    { ingredient: "Olive Oil",       quantity: 3,  unit: "tbsp" },
    { ingredient: "Parmesan",        quantity: 2,  unit: "oz" }
  ],
  "Turkey Meatball Soup" => [
    { ingredient: "Ground Turkey",   quantity: 1,   unit: "lb" },
    { ingredient: "Vegetable Broth", quantity: 4,   unit: "cup" },
    { ingredient: "Diced Tomatoes",  quantity: 1,   unit: "can" },
    { ingredient: "Baby Spinach",    quantity: 2,   unit: "cup" },
    { ingredient: "Garlic",          quantity: 2,   unit: "clove" },
    { ingredient: "Onion",           quantity: 0.5, unit: "each" }
  ],
  "Sweet Potato Black Bean Tacos" => [
    { ingredient: "Sweet Potato", quantity: 2, unit: "each" },
    { ingredient: "Black Beans",  quantity: 1, unit: "cup" },
    { ingredient: "Tortillas",    quantity: 8, unit: "each" },
    { ingredient: "Avocado",      quantity: 1, unit: "each" },
    { ingredient: "Olive Oil",    quantity: 2, unit: "tbsp" }
  ],
  "Salmon with Roasted Broccoli" => [
    { ingredient: "Salmon Fillet", quantity: 0.75, unit: "lb" },
    { ingredient: "Broccoli",      quantity: 1,    unit: "head" },
    { ingredient: "Olive Oil",     quantity: 2,    unit: "tbsp" },
    { ingredient: "Lemon",         quantity: 1,    unit: "each" },
    { ingredient: "Garlic",        quantity: 2,    unit: "clove" }
  ],
  "Chickpea Tikka Masala" => [
    { ingredient: "Chickpeas",      quantity: 2,   unit: "cup" },
    { ingredient: "Coconut Milk",   quantity: 1,   unit: "can" },
    { ingredient: "Diced Tomatoes", quantity: 1,   unit: "can" },
    { ingredient: "Onion",          quantity: 1,   unit: "each" },
    { ingredient: "Garlic",         quantity: 3,   unit: "clove" },
    { ingredient: "Olive Oil",      quantity: 2,   unit: "tbsp" }
  ],
  "Ground Turkey Zucchini Skillet" => [
    { ingredient: "Ground Turkey",  quantity: 1,   unit: "lb" },
    { ingredient: "Zucchini",       quantity: 2,   unit: "each" },
    { ingredient: "Diced Tomatoes", quantity: 1,   unit: "can" },
    { ingredient: "Garlic",         quantity: 3,   unit: "clove" },
    { ingredient: "Onion",          quantity: 1,   unit: "each" },
    { ingredient: "Olive Oil",      quantity: 1,   unit: "tbsp" }
  ]
}

recipe_ingredients_data.each do |recipe_name, ingredients|
  r = Recipe.find_by(name: recipe_name)
  next puts "  ⚠️  Recipe not found: #{recipe_name}" unless r

  ingredients.each do |attrs|
    ingredient = Ingredient.find_by(name: attrs[:ingredient].strip.titleize)
    next puts "  ⚠️  Ingredient not found: #{attrs[:ingredient]}" unless ingredient

    RecipeIngredient.find_or_create_by!(recipe: r, ingredient: ingredient) do |ri|
      ri.quantity = attrs[:quantity]
      ri.unit     = attrs[:unit]
    end
  end
end

puts "  → #{RecipeIngredient.count} recipe ingredients"

# ─────────────────────────────────────────────────────────────────────────────
# Demo user (development only)
# ─────────────────────────────────────────────────────────────────────────────
if Rails.env.development?
  puts "👤  Seeding demo user…"

  demo = User.find_or_create_by!(email_address: "demo@example.com") do |u|
    u.password            = "password1234"
    u.display_name        = "Demo User"
    u.onboarding_complete = true
    u.onboarding_step     = "complete"
    u.admin               = false
  end
  # Ensure existing demo user has admin flag
  demo.update!(admin: true) unless demo.admin?

  unless demo.user_preference
    demo.create_user_preference!(
      dietary_restrictions:  [],
      preferred_cuisines:    %w[american mexican latin asian],
      household_size:        4,
      cooking_skill:         "intermediate",
      weekly_budget:         200,
      zip_code:              "33131",
      preferred_store:       "Publix",
      meals_per_week:        14,
      meal_complexity:       "moderate",
      include_breakfast:     true,
      include_lunch:         true,
      include_dinner:        true
    )
  end

  puts "  → demo@saveandsavor.com / password1234"

  puts "👤  Seeding admin user…"

  demo = User.find_or_create_by!(email_address: "admin@example.com") do |u|
    u.password            = "password1234"
    u.display_name        = "Admin User"
    u.onboarding_complete = true
    u.onboarding_step     = "complete"
    u.admin               = true
  end
  # Ensure existing demo user has admin flag
  demo.update!(admin: true) unless demo.admin?

  unless demo.user_preference
    demo.create_user_preference!(
      dietary_restrictions:  [],
      preferred_cuisines:    %w[american mexican latin asian],
      household_size:        4,
      cooking_skill:         "intermediate",
      weekly_budget:         200,
      zip_code:              "33131",
      preferred_store:       "Publix",
      meals_per_week:        14,
      meal_complexity:       "moderate",
      include_breakfast:     true,
      include_lunch:         true,
      include_dinner:        true
    )
  end

  puts "  → admin@example.com / password1234"
end

# ─────────────────────────────────────────────────────────────────────────────
# Stores — default Publix (chain-wide weekly ad)
# ─────────────────────────────────────────────────────────────────────────────

puts "🌱  Seeding stores…"

# Chain-wide record used by the scraper (no store_number = all-Publix weekly ad)
publix = Store.find_or_create_by!(chain: "publix", store_number: nil) do |s|
  s.name       = "Publix"
  s.scrape_url = "https://www.publix.com/savings/weekly-ad/view-all"
end

puts "  → #{publix.name} (chain-wide weekly ad)"

# ── Miami-Dade individual Publix locations ────────────────────────────────
miami_publix_locations = [
  { name: "Publix — Brickell",           address: "1 SE 1st Ave",          city: "Miami",            zip_code: "33131", store_number: "0531" },
  { name: "Publix — South Beach",        address: "1045 Dade Blvd",        city: "Miami Beach",      zip_code: "33139", store_number: "0245" },
  { name: "Publix — Coral Gables",       address: "3225 S Dixie Hwy",      city: "Miami",            zip_code: "33133", store_number: "0534" },
  { name: "Publix — Coconut Grove",      address: "2828 SW 27th Ave",      city: "Miami",            zip_code: "33133", store_number: "0692" },
  { name: "Publix — Midtown Miami",      address: "3401 N Miami Ave",      city: "Miami",            zip_code: "33127", store_number: "1348" },
  { name: "Publix — Doral",              address: "3750 NW 87th Ave",      city: "Doral",            zip_code: "33178", store_number: "1227" },
  { name: "Publix — Kendall",            address: "8725 SW 136th St",      city: "Miami",            zip_code: "33176", store_number: "0660" },
  { name: "Publix — Hialeah",            address: "900 W 49th St",         city: "Hialeah",          zip_code: "33012", store_number: "0179" },
  { name: "Publix — Aventura",           address: "2960 Aventura Blvd",    city: "Aventura",         zip_code: "33180", store_number: "0524" },
  { name: "Publix — North Miami Beach",  address: "1225 NE 163rd St",      city: "North Miami Beach", zip_code: "33162", store_number: "0381" },
  { name: "Publix — Homestead",          address: "2525 NE 8th St",        city: "Homestead",        zip_code: "33033", store_number: "0722" },
  { name: "Publix — Cutler Bay",         address: "10710 Caribbean Blvd",  city: "Cutler Bay",       zip_code: "33189", store_number: "1103" }
]

# Individual Miami stores inherit deals from the chain-wide parent.
# scrape_url is nil until Publix exposes a per-store URL format.
# TODO: when per-store URL is confirmed, set scrape_url to e.g.
#       "https://www.publix.com/savings/weekly-ad/{store_number}"
miami_publix_locations.each do |attrs|
  store = Store.find_or_initialize_by(chain: "publix", store_number: attrs[:store_number])
  store.assign_attributes(
    name:           attrs[:name],
    address:        attrs[:address],
    city:           attrs[:city],
    state:          "FL",
    zip_code:       attrs[:zip_code],
    parent_store:   publix,
    scrape_url:     nil
  )
  store.save!
end

puts "  → #{Store.where(chain: 'publix').count} Publix store records total"

# ── Kroger chain-wide record ─────────────────────────────────────────────────
# TODO: verify DOM selectors in Scrapers::KrogerScraper before running FetchDealsJob
kroger = Store.find_or_create_by!(chain: "kroger", store_number: nil) do |s|
  s.name       = "Kroger"
  s.scrape_url = "https://www.kroger.com/d/weekly-ad"
  s.city       = nil
  s.state      = nil
end
puts "  → Kroger chain-wide store: #{kroger.name}"

# ── Aldi chain-wide record ───────────────────────────────────────────────────
# TODO: verify DOM selectors in Scrapers::AldiScraper before running FetchDealsJob
aldi = Store.find_or_create_by!(chain: "aldi", store_number: nil) do |s|
  s.name       = "Aldi"
  s.scrape_url = "https://www.aldi.us/en/weekly-specials/"
  s.city       = nil
  s.state      = nil
end
puts "  → Aldi chain-wide store: #{aldi.name}"

# Wire demo user to the chain-wide Publix store
if Rails.env.development?
  demo = User.find_by(email_address: "demo@saveandsavor.com")
  if demo && publix
    UserStore.find_or_create_by!(user: demo, store: publix) { |us| us.primary = true }
    puts "  → demo user linked to #{publix.name}"
  end
end

puts "✅  Seeds complete."
