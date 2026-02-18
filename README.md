# Animal Shelter Data Optimization & Adoption Analysis 

## Overview

This project analyzes an animal shelter dataset using SQL to clean, standardize, and evaluate adoption trends. The work focuses on improving data quality, identifying adoption patterns, and measuring shelter performance metrics.

The project was completed using MySQL for querying and Tableau for visualization.

---

## Dataset Description

The dataset contains animal intake and outcome records, including animal identifiers, demographics, intake reasons, outcomes, and breed information. The data required cleaning due to duplicate records, inconsistent age formats, redundant columns, and non-adoptable animal entries.

---

## Project Objectives

* Detect and remove duplicate records safely.
* Standardize inconsistent age data for analysis.
* Remove redundant or low-value columns.
* Filter out non-adoptable animal records.
* Analyze adoption trends by animal type, breed, age, and month.
* Measure shelter performance metrics such as adoption rates and average stay duration.

---

## Methodology

### 1. Data Cleaning & Preparation

* Created a working copy of the original dataset to preserve raw data integrity.
* Checked for duplicate primary keys and duplicate full rows using GROUP BY and ROW_NUMBER().
* Added a temporary auto-increment ID column to safely remove duplicates.
* Deleted redundant or high-null columns that did not add analytical value.
* Removed livestock records to focus analysis on adoptable animals.

### 2. Data Standardization

* Converted mixed-format age values (days, weeks, months, years) into a single numeric field measured in months.
* Validated the new age column before dropping the original inconsistent age column.
* Corrected invalid breed entries and removed incorrect rows.

### 3. Exploratory Data Analysis

* Counted animals by type and identified total adoptions.
* Measured adoptable intakes per month.
* Calculated monthly and average adoptions.
* Identified most-adopted cat and dog breeds.
* Evaluated outcome distributions by animal type and breed.
* Measured adoption age distribution.
* Calculated average shelter stay duration before adoption.

---

## Key Findings

* Duplicate rows were identified and safely removed to improve reporting accuracy.
* Standardizing age values enabled clearer adoption trend analysis.
* Adoption counts varied by breed and animal type, highlighting high-demand categories.
* Monthly intake and adoption tracking provided visibility into shelter capacity trends.
* Average stay calculations helped measure adoption efficiency.

---

## Skills Demonstrated

* SQL data cleaning and transformation
* Duplicate detection and removal
* Data validation and integrity checks
* Aggregation and segmentation analysis
* KPI tracking and trend analysis
* Preparing datasets for Tableau visualization

---

## Tools Used

* MySQL
* Tableau

---

## How to Reproduce

1. Import the original animals dataset into MySQL.
2. Create a working copy of the table.
3. Run duplicate detection and cleanup queries.
4. Standardize the age column into months.
5. Execute analysis queries grouped by objectives.
6. Export results for visualization in Tableau.

---
