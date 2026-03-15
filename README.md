<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=2,3,12&height=160&section=header&text=E-Commerce%20Sales%20Analysis&fontSize=36&fontColor=fff&animation=fadeIn&fontAlignY=38&desc=End-to-end%20SQL%20analysis%20of%20orders%2C%20revenue%2C%20products%20%26%20customers&descAlignY=58&descSize=14"/>

</div>

<div align="center">

![SQL](https://img.shields.io/badge/SQL-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-22C55E?style=for-the-badge)
![Queries](https://img.shields.io/badge/SQL%20Files-5-F97316?style=for-the-badge)
![Techniques](https://img.shields.io/badge/Window%20Functions-CTEs-8B5CF6?style=for-the-badge)
![Author](https://img.shields.io/badge/Author-Dheeraj%20Kandpal-58A6FF?style=for-the-badge)

</div>

---

## 📌 Project Overview

This project performs a **full-stack SQL analysis** on a simulated Indian e-commerce business.
The goal: answer the questions a business stakeholder would actually ask — not just write queries for the sake of it.

> **"Which customers are worth keeping? Which products are killing margin? Where is revenue leaking?"**

The entire analysis is done in pure SQL — no Python, no BI tool. Just structured queries that tell a clear business story.

---

## 🎯 Business Questions Answered

| # | Question | File |
|---|----------|------|
| 1 | What is the overall revenue, profit, and average order value? | `02_revenue_trends.sql` |
| 2 | How is monthly revenue trending year-over-year? | `02_revenue_trends.sql` |
| 3 | Which regions and shipping modes drive the most revenue? | `02_revenue_trends.sql` |
| 4 | Which products and categories generate the most profit? | `03_product_performance.sql` |
| 5 | How does discounting affect profit margins? | `03_product_performance.sql` |
| 6 | Who are the most valuable customers? (RFM analysis) | `04_customer_segmentation.sql` |
| 7 | What is each customer's estimated lifetime value (CLV)? | `05_advanced_insights.sql` |
| 8 | Which day of the week drives the most orders? | `05_advanced_insights.sql` |
| 9 | What's the MoM revenue growth per region? | `05_advanced_insights.sql` |
| 10 | Full executive KPI summary in a single query | `05_advanced_insights.sql` |

---

## 🗂️ Project Structure

```
ecommerce-sales-analysis/
│
├── queries/
│   ├── 01_schema_and_data.sql      ← Database schema + sample data
│   ├── 02_revenue_trends.sql       ← Monthly/regional/YoY revenue
│   ├── 03_product_performance.sql  ← Top products, margins, discount impact
│   ├── 04_customer_segmentation.sql← RFM model, CLV, segment analysis
│   └── 05_advanced_insights.sql    ← Window functions, MoM, exec summary
│
├── assets/
│   └── schema_diagram.png          ← ERD (Entity Relationship Diagram)
│
└── README.md
```

---

## 🗃️ Database Schema

```
customers ──────────┐
  customer_id  (PK) │
  customer_name     │
  segment           │
  city / state      │
                    ▼
               orders
               order_id   (PK)
               customer_id (FK) ──► customers
               order_date
               ship_mode
               region
                    │
                    ▼
             order_items
             item_id    (PK)
             order_id   (FK) ──► orders
             product_id (FK) ──► products
             quantity / discount / sales / profit
                    │
                    ▼
              products
              product_id   (PK)
              category / sub_category
              cost_price / sell_price
```

**4 tables · 25 products · 20 orders · 10 customers · 2 years of data**

---

## 🔍 Key Insights

### 💰 Revenue & Profitability
- **Technology** is the top revenue category, contributing over **65% of gross revenue**
- Average order value sits around **₹42,000** — driven heavily by laptops and monitors
- Overall profit margin is approximately **28%** — healthy, but discounts above 10% drop it below 20%

### 📦 Product Performance
- **Apple MacBook Pro** and **Samsung Galaxy S23** are the top 2 revenue drivers
- **Office Supplies** (Paper, Pens, Notebooks) have the **highest volume** but lowest margin
- Products with discounts above 10% show a sharp margin decline — worth reviewing the discount policy

### 👤 Customer Behaviour
- **Corporate segment** customers spend 2× more per order than Consumer segment
- RFM analysis reveals 3 "Champion" customers who should be prioritised for retention
- **South region** leads in order volume; **North region** leads in average order size

### 📅 Timing Patterns
- **2023 shows strong YoY growth** vs 2022 across all regions
- Q4 (Oct–Dec) is the highest-revenue quarter — driven by festive season orders

---

## 🛠️ SQL Techniques Used

| Technique | Where Used |
|-----------|-----------|
| `JOIN` (INNER, multiple tables) | All files |
| `GROUP BY` + aggregate functions | All files |
| `CASE WHEN` | Discount bands, RFM scoring |
| Common Table Expressions (`WITH`) | Files 04, 05 |
| Window functions (`LAG`, `RANK`, `ROW_NUMBER`, `NTILE`, `SUM OVER`) | Files 03, 04, 05 |
| `DATE_FORMAT`, `DATEDIFF`, `TIMESTAMPDIFF` | Files 02, 05 |
| Subqueries | File 03 |
| `NULLIF` (division safety) | Files 03, 05 |

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+ (or MariaDB 10.6+)
- MySQL Workbench, DBeaver, or any SQL client

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/DheerajKandpal/ecommerce-sales-analysis.git
cd ecommerce-sales-analysis

# 2. Open your SQL client and run files in order:
#    01 → 02 → 03 → 04 → 05

# 3. Start with schema setup
SOURCE queries/01_schema_and_data.sql;

# 4. Then run any analysis file
SOURCE queries/02_revenue_trends.sql;
```

> ⚠️ Run `01_schema_and_data.sql` first — it creates the database and inserts all sample data.

---

## 📸 Sample Output

### Executive KPI Summary (Query from `05_advanced_insights.sql`)

| total_orders | unique_customers | gross_revenue | gross_profit | margin_pct | avg_order_value |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 20 | 10 | ₹8,82,913 | ₹2,47,660 | 28.05% | ₹44,146 |

### Top Products by Revenue

| product_name | category | units_sold | total_revenue | margin_pct |
|---|---|:---:|:---:|:---:|
| Apple MacBook Pro 14" | Technology | 2 | ₹2,51,550 | 24.2% |
| Samsung Galaxy S23 | Technology | 3 | ₹2,16,000 | 23.6% |
| Herman Miller Chair | Furniture | 2 | ₹1,04,500 | 32.8% |
| Dell 27" Monitor | Technology | 3 | ₹89,600 | 30.1% |

### RFM Customer Segments

| rfm_segment | customers | avg_clv |
|---|:---:|:---:|
| Champions | 3 | ₹1,84,000 |
| Loyal Customers | 3 | ₹92,000 |
| Potential Loyalists | 2 | ₹54,000 |
| Need Attention | 2 | ₹28,000 |

---

## 📬 Connect

<div align="center">

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Dheeraj%20Kandpal-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/dheerajkandpal)
[![GitHub](https://img.shields.io/badge/GitHub-DheerajKandpal-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/DheerajKandpal)
[![Email](https://img.shields.io/badge/Email-dheeraj.kandpal%40surepass.io-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:dheeraj.kandpal@surepass.io)

</div>

---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=2,3,12&height=80&section=footer"/>
<sub>Built with 🔍 SQL · Queries are production-ready and fully commented</sub>
</div>
