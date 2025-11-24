# 🏏 RR 2026 IPL Auction Strategy: Squad Optimization & Budget Modeling

![Status](https://img.shields.io/badge/Status-Completed-success)
![Focus](https://img.shields.io/badge/Focus-Auction_Strategy-pink)
![Budget](https://img.shields.io/badge/Purse_Remaining-₹16.05_Cr-green)

## 📄 Project Overview
This project formulates a data-driven auction strategy for the **Rajasthan Royals (RR)** ahead of the IPL 2026 Auction.

Following the retention phase, the team has a remaining purse of **~₹16.05 Cr**. This analysis utilizes 2020-2025 T20 data to identify high-value targets who fill specific structural voids, specifically finding a leg-spinner to partner with Ravindra Jadeja, securing Indian wicket-keeping depth and agressive overseas anchor (to replace Sanju).

## 🎯 Strategic Objectives
The analysis identifies three critical gaps in the post-retention squad:
1. **Specialist Leg-Spinner:** To complement Jadeja (Left-arm Orth).
2. **Backup Indian Wicket-Keeper:** A young Indian option capable of batting in the middle order (No. 3-5) to cover for Dhruv Jurel when he's unavailable.
3. **Overseas Batting Contingency:** An established right-handed overseas batter if the primary all-rounder target is missed.

## 📊 Methodology & Custom Metrics
The analysis filters for players with significant sample sizes and evaluates them using custom Key Performance Indicators (KPIs):

| Metric | Definition | Purpose |
| :--- | :--- | :--- |
| **Multiwicket Frequency** | `Matches with >1 Wicket / Total Matches` | Identifies bowlers who break partnerships rather than just containing runs. |
| **Defensive Reliability** | `Economy Rate in Wicketless Games` | **Risk Management:** Measures how expensive a bowler is on their "bad days". |
| **Strike Rotation Rate** | `Strike Rate on Non-Boundary Balls` | Evaluates a batter's ability to keep the scoreboard moving without taking risks. |
| **High-Impact Probability** | `Innings with Runs ≥30 & SR ≥150` | Isolates match-winning performances from average accumulators. |

## 🧠 Scenario Planning & Squad Composition

The strategy employs a **Conditional Decision Tree** based on the availability of the primary target, Rishad Hossain.

### Scenario A: The "Primary Target" Success 
* **Target:** **Rishad Hossain** (Max Bid: ₹9.0 Cr)
* **Squad Role:** Plays at No. 8 as the specialist spinner and lower-order hitter.
* **Result:** The overseas slot is filled by Rishad; no additional overseas batter is required.

### Scenario B: The "Backup" Pivot 
* **Trigger:** If Rishad Hossain's price exceeds ₹9.0 Cr.
* **Action:**
    1.  Acquire **Prashant Solanki** (Leggie) as the primary spinner (Max Bid: ₹4.0 Cr).
    2.  Utilize the saved funds to buy a premium overseas batter like **Daryl Mitchell** or **Shai Hope** (Max Bid: ₹9.0 Cr) to bat at No. 3.

## 📉 Valuation Model (Max Bid Caps)
The following bid ceilings were calculated to ensure the team secures one primary option from each category without exceeding the ₹16.05 Cr purse.

| Priority | Player | Role | Base Price | **Max Model Bid** | Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Rishad Hossain** | All-Rounder (Leggie) | ₹0.50 Cr | **₹9.00 Cr** | Perfect balance of spin + batting depth. |
| **Alt** | **Daryl Mitchell** | Overseas Batter | ₹1.00 Cr | **₹9.00 Cr** | Priority target if Rishad is missed; high consistency anchor. |
| **Alt** | **Shai Hope** | Overseas Batter | ₹1.00 Cr | **₹9.00 Cr** | Backup to Mitchell; excellent spin player. |
| **2** | **Prashant Solanki** | Leg Spinner | ₹0.30 Cr | **₹4.00 Cr** | Best available Indian leggie; essential if Rishad is missed. |
| **3** | **Tushar Raheja** | Indian WK | ₹0.30 Cr | **₹1.50 Cr** | Strong TNPL performance; high Strike Rotation Rate. |
| **4** | **KC Cariappa** | Leg Spinner | ₹0.30 Cr | **₹0.50 Cr** | Budget backup spinner. |
| **5** | **Tejasvi Dahiya** | Indian WK | ₹0.30 Cr | **₹0.40 Cr** | Value backup option likely available at base price. |

**Total Projected Spend:** ~₹15.40 Cr (leaving ₹0.65 Cr buffer).

🔒 **Full Auction Strategy:** is available in the **[Full PDF Report](./Auction_Strategy.pdf)**
---
*Disclaimer: This project is a fan-made analysis for the IPL 2026 Auction and is not affiliated with the Rajasthan Royals franchise.*
