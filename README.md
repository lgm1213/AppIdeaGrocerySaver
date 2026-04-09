# Save & Savor

Grocery shopping should not mean choosing between eating well and spending smart. Save & Savor bridges that gap — it tracks what's on sale at your local Publix, then builds a weekly meal plan around those deals so you always know what to cook and why it saves you money.

---

## The idea

Most grocery savings apps tell you what's on sale. Most meal planning apps tell you what to cook. Neither talks to the other.

Save & Savor connects them. When chicken thighs go on sale, your meal plan fills up with chicken recipes. When your plan is generated, you can see exactly which ingredients are on sale and how much you're saving. When you cook a meal, you can rate it — and those ratings feed back into future suggestions so the app learns what you actually like.

---

## What's been built

**Deal intelligence**
Weekly Publix deals are automatically scraped every Wednesday and matched to the ingredients in the recipe database. Deals surface everywhere — on the meal plan calendar, inside shopping lists, and in the recipe browser.

**Meal planning**
The meal generator scores recipes by combining active deal savings, your personal preferences (liked and blocked recipes), and community ratings from other users. The result is a week of meals that reflect both what's cheap and what you'll actually want to eat.

**Recipe browser**
Browse recipes by meal type, cuisine, dietary preference, or filter to only show recipes where ingredients are currently on sale. Rate recipes after cooking and like or block them to shape future suggestions.

**Shopping lists**
Generated directly from a meal plan. Items with active deals are flagged inline so you know what to prioritize at the store.

**Savings dashboard**
A running view of your estimated deal savings, weekly spend vs. your budget, and how consistently you're cooking the meals you plan.

**Admin panel**
Internal tooling for triggering scrape jobs, monitoring background job activity in real time, managing users, and configuring email delivery — all without touching the server.

---

## Status

Active development. Core features (deals, meal planning, recipe preferences, shopping lists, savings tracking) are complete. Deployment infrastructure is in place via Kamal. The next focus is smart deal alerts and letting users add their own recipes.

---

Built with Ruby on Rails 8.1.
