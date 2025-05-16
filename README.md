# 📈 US Economic Forecast Dashboard (R Shiny)

This is an interactive dashboard I built using R Shiny to explore and forecast key U.S. economic indicators over time. It pulls from the built-in `economics` dataset in R and lets users visualize trends, compare variables, and even forecast future values.

I designed this app to help practice both time series forecasting and interactive data storytelling — and to make economic data more engaging and accessible.

---

## 💡 What This Project Does

- 📊 Forecasts economic indicators using an ETS model (Exponential Smoothing)
- 📈 Lets users choose which variable to forecast (like unemployment or savings rate)
- 📅 Adjust how many months ahead to predict (6 to 60 months)
- 🔁 Filters the time range interactively
- 🔍 Compares two variables in a scatter plot
- 📊 Generates a correlation heatmap between key economic indicators
- 🧮 Shows trend, average, latest value, and percent change with clean value boxes

---

## 🛠 Tools & Technologies

- **R** + **R Shiny**
- Libraries: `forecast`, `ggplot2`, `plotly`, `shinydashboard`, `dplyr`, `DT`, `lubridate`

---

## 📁 Dataset Info

- Built-in `economics` dataset from the `ggplot2` package
- Monthly data from 1967 onward
- Includes variables like:
  - Personal consumption (`pce`)
  - Population (`pop`)
  - Unemployment rate (`unemploy`)
  - Median duration of unemployment (`uempmed`)
  - Personal savings rate (`psavert`)

---

## 🖥 How to Try It

1. Download or clone this repo
2. Open the `Dashboard_CA2.R` file in RStudio
3. Click "Run App" — and it will launch in your browser

---

## 🎯 Why I Built This

I wanted to combine time series forecasting with dynamic UI design. This project helped me improve my skills in:
- Data filtering and transformation in R
- Building dashboards with `shinydashboard`
- Making visuals interactive with `plotly`
- Creating useful outputs like value boxes and forecasts

It was a great learning experience — and I’d love feedback!

---

## 📸 Preview
![R_Dashboard_Recording-gif](https://github.com/user-attachments/assets/a7c497bc-fc35-4760-ace7-db94022cabfa)

---

**Created by Sukriti Kakkar — thanks for checking it out!**
