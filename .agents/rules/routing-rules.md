---
trigger: always_on
---

# ROUTING RULES (EN)

## DEEP LINK RULES
1. Deep link parsing belongs to Router layer, not Controller or Repository.
2. After parsing, extract route parameters (for example, event ID) and navigate through the normal app route flow.
3. Destination screens must load data through their own Controller -> Repository flow.
4. Do not bypass Repository to fetch data directly from deep link handler.

## ROUTING SCOPE
1. This rule governs navigation and deep link handling only.
2. Data contract, DTO mapping, and cache strategy belong to `data_mapping_rules.md`.
