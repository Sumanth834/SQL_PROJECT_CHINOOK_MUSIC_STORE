
# 🎵 Music Sales Analytics — SQL + Power BI Project

This project presents a comprehensive sales and customer analysis for a global music distribution platform, leveraging **Advanced SQL (MySQL)** for deep querying and **Power BI** for interactive visual storytelling.

---

## 📌 Objectives

- Identify **top-performing albums** for promotional campaigns.
- Analyze **global genre preferences** and regional trends.
- Understand **customer purchase behavior** (long-term vs new).
- Discover **product affinity** patterns to guide bundling and recommendations.

---

## 🛠️ Tools & Technologies

- **SQL (MySQL 8.0.40)**  
  Advanced queries using:
  - `DENSE_RANK()` & `ROW_NUMBER()` for ranking logic
  - `JOINs`, `CTEs`, and `DATE_DIFF()` for behavioral segmentation
  - Set-based logic for affinity combinations

- **Power BI**
  - Multi-page dashboard for genre sales, customer segmentation, and campaign insights
  - KPI cards, slicers, matrix visuals, and bar charts

---

## 📊 Key Analyses

### 1. 🎯 Top Albums for U.S. Promotion

- **Method**: `DENSE_RANK()` based on total sales (albums with >4 units).
- **Genres Prioritized**: Rock, Alternative & Punk, Metal
- **Top Picks**:
  - *Are You Experienced*, *The Doors*, *From the Muddy Banks...* (Rock)
  - *Green* (Alt/Punk)
  - *Mesmerize*, *Faceless* (Metal)

**Strategy**: Leverage these for multi-channel campaigns, merchandising, and concert promotions.

---

### 2. 🌎 Global Genre Preference

- **Method**: `ROW_NUMBER()` partitioned by country (excluding USA).
- **Commonalities**:
  - Rock: Dominates across all regions
  - Alt & Punk + Metal: Appear in top 3 globally
- **Regional Variations**:
  - Jazz (Austria, Germany), Latin (Argentina), R&B (Netherlands), Easy Listening (France)

**Actionable Insight**: Localize campaigns while maintaining a global rock-heavy core catalog.

---

### 3. 🧾 Customer Behavior Analysis

- **Segmentation**:
  - Long-Term: Tenure ≥ 1050 days
  - Short-Term: Tenure < 1050 days
- **Findings**:
  - Long-term customers show higher frequency, basket size, and total spend
  - New customers show promising AOV but lower retention

**Strategy**: Focus on retention via loyalty perks, and optimize onboarding for new customers.

---

### 4. 🔁 Product Affinity Analysis

- **Genre Pairs**:  
  - Rock–Metal, Rock–Alt & Punk (High overlap)

- **Artist Combos**:  
  - Nirvana–Eric Clapton, Queen–U2, Green Day–Guns N' Roses

- **Album Combos**:  
  - *Mezmerize* + *Are You Experienced*, *Dark Side of the Moon* + *The Singles*

**Strategy**: Use bundles, “frequently bought together” suggestions, and curated playlists.

---

## 🧠 Strategic Takeaways

- Double down on **Rock + Alt/Punk + Metal** globally.
- Tailor **localized strategies** with niche genres per market.
- Promote **bundle offers** using artist & album affinity data.
- Design **customer lifecycle programs** focusing on long-term retention.

---

## SUMMARY
This project demonstrates how structured relational data combined with advanced SQL and intuitive BI tools can surface **actionable insights** to drive sales, retention, and global marketing strategy.

