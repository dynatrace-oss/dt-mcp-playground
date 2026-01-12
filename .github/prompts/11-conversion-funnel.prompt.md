---
description: 'Analyze e-commerce conversion funnel from business events'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** Business events can be data-intensive. To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-24h` maximum for business event queries (funnel analysis needs sufficient data)
- **Result limits**: Always include `| limit 20` when discovering event types
- **Aggregation required**: Use `summarize` with `countIf()` - never fetch raw business events

---

Your goal is to analyze the e-commerce conversion funnel using Dynatrace business events.

## Purpose

Track and analyze the customer journey from product discovery to purchase completion, identifying drop-off points and calculating conversion rates between funnel stages.

## Step-by-Step Instructions

### Step 1: Discover Available Business Event Types

First, understand what business events are being tracked in your environment.

```dql
fetch bizevents, from:now()-24h
| summarize event_count = count(), by:{event.type}
| sort event_count desc
| limit 20
```

**What to look for**:
- Event types related to e-commerce actions (product views, cart, checkout, purchase)
- Common naming patterns (e.g., `*.product.view`, `*.cart.add`, `*.checkout.*`, `*.purchase.*`)
- Volume distribution across event types

### Step 2: Build the Funnel Stage Counts

Query business events from the last 24 hours and count events for each funnel stage. Adjust the event type names based on what you discovered in Step 1.

```dql
fetch bizevents, from:now()-24h
| summarize
    product_views = countIf(contains(event.type, "product") AND contains(event.type, "view")),
    cart_additions = countIf(contains(event.type, "cart") OR contains(event.type, "add")),
    checkout_started = countIf(contains(event.type, "checkout") AND NOT contains(event.type, "success")),
    purchases = countIf(contains(event.type, "purchase") OR contains(event.type, "checkout_success") OR contains(event.type, "order"))
```

**Note**: The exact event type names vary by implementation. Common patterns include:
- Product viewed: `product.view`, `product.details`, `products`
- Added to cart: `cart.add`, `add_to_cart`, `cart`
- Checkout started: `checkout.start`, `checkout.begin`, `checkout`
- Purchase completed: `purchase`, `checkout_success`, `order.complete`

### Step 3: Calculate Conversion Rates Between Stages

Add calculated fields for conversion rates between each consecutive stage.

```dql
fetch bizevents, from:now()-24h
| summarize
    product_views = countIf(contains(event.type, "product")),
    cart_additions = countIf(contains(event.type, "cart")),
    checkout_started = countIf(contains(event.type, "checkout") AND NOT contains(event.type, "success")),
    purchases = countIf(contains(event.type, "purchase") OR contains(event.type, "success"))
| fieldsAdd
    view_to_cart_rate = if(product_views > 0, (cart_additions * 100.0) / product_views, else: 0),
    cart_to_checkout_rate = if(cart_additions > 0, (checkout_started * 100.0) / cart_additions, else: 0),
    checkout_to_purchase_rate = if(checkout_started > 0, (purchases * 100.0) / checkout_started, else: 0),
    overall_conversion_rate = if(product_views > 0, (purchases * 100.0) / product_views, else: 0)
```

### Step 4: Format Results as a Funnel Table

Create a readable table format showing each funnel stage with its count and conversion rate to the next stage.

```dql
fetch bizevents, from:now()-24h
| summarize
    product_views = countIf(contains(event.type, "product")),
    cart_additions = countIf(contains(event.type, "cart")),
    checkout_started = countIf(contains(event.type, "checkout")),
    purchases = countIf(contains(event.type, "purchase") OR contains(event.type, "success"))
| fieldsAdd
    stage1_name = "Product Viewed",
    stage1_count = product_views,
    stage1_rate = 100.0,
    stage2_name = "Added to Cart",
    stage2_count = cart_additions,
    stage2_rate = if(product_views > 0, round((cart_additions * 100.0) / product_views, decimals: 2), else: 0),
    stage3_name = "Checkout Started",
    stage3_count = checkout_started,
    stage3_rate = if(cart_additions > 0, round((checkout_started * 100.0) / cart_additions, decimals: 2), else: 0),
    stage4_name = "Purchase Completed",
    stage4_count = purchases,
    stage4_rate = if(checkout_started > 0, round((purchases * 100.0) / checkout_started, decimals: 2), else: 0),
    overall_conversion = if(product_views > 0, round((purchases * 100.0) / product_views, decimals: 2), else: 0)
| fields
    stage1_name, stage1_count, stage1_rate,
    stage2_name, stage2_count, stage2_rate,
    stage3_name, stage3_count, stage3_rate,
    stage4_name, stage4_count, stage4_rate,
    overall_conversion
```

## Expected Output

Your final result should display:

| Funnel Stage | Event Count | Conversion Rate to Next Stage (%) |
|--------------|-------------|-----------------------------------|
| Product Viewed | X | 100.0 (baseline) |
| Added to Cart | Y | Y/X * 100 |
| Checkout Started | Z | Z/Y * 100 |
| Purchase Completed | W | W/Z * 100 |

Plus the overall conversion rate: (Purchases / Product Views) * 100

## Key Insights to Report

When presenting results, explain:
- **Biggest drop-off point**: Which stage has the lowest conversion rate?
- **Cart abandonment rate**: How many users add to cart but don't start checkout?
- **Checkout abandonment rate**: How many users start but don't complete checkout?
- **Overall funnel health**: Is the overall conversion rate within expected range (typically 1-5% for e-commerce)?

## Troubleshooting

**No business events found?**
- Verify business events are configured in your Dynatrace environment
- Check if the application has the Dynatrace RUM or OneAgent instrumented
- Extend the time range if events are infrequent

**Event type names don't match?**
- Run Step 1 first to discover actual event type names in your environment
- Adjust the filter conditions in subsequent queries to match your naming convention
