# Load libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(forecast)
library(lubridate)
library(DT)
library(dplyr)

# Load dataset
data("economics")
# UI
ui <- dashboardPage(
  dashboardHeader(title = "US Economic Forecast Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "Dashboard", icon = icon("dashboard")),
      selectInput("variable", "Select Variable:",
                  choices = names(economics)[2:6],
                  selected = "unemploy"),
      sliderInput("monthsAhead", "Months to Forecast:",
                  min = 6, max = 60, value = 12, step = 6),
      selectInput("xvar", "X-axis Variable (Scatter):",
                  choices = names(economics)[2:6],
                  selected = "pop"),
      selectInput("yvar", "Y-axis Variable (Scatter):",
                  choices = names(economics)[2:6],
                  selected = "unemploy"),
      dateRangeInput("dateRange", "Select Date Range:",
                     start = min(economics$date),
                     end = max(economics$date),
                     min = min(economics$date),
                     max = max(economics$date))
    )
  ),
  
  dashboardBody(
    fluidRow(
      box(width = 12, title = "Time Series with Forecast (ETS Model)", solidHeader = TRUE, status = "primary",
          plotlyOutput("forecastPlot"))
    ),
    
    fluidRow(
      valueBoxOutput("latestValueBox", width = 3),
      valueBoxOutput("averageValueBox", width = 3),
      valueBoxOutput("trendDirectionBox", width = 3),
      valueBoxOutput("percentChangeBox", width = 3)
    ),
    
    fluidRow(
      box(width = 12, title = "Predicted Values Table", solidHeader = TRUE, status = "info",
          DT::dataTableOutput("predictedValuesTable"))
    ),
    
    fluidRow(
      box(width = 12, title = "Variable Relationship Scatter Plot", solidHeader = TRUE, status = "primary",
          plotlyOutput("scatterPlot"))
    ),
    
    fluidRow(
      box(width = 12, title = "Correlation Heatmap", solidHeader = TRUE, status = "warning",
          plotOutput("correlationPlot"))
    )
  )
)

# Server
server <- function(input, output) {
  
  filtered_data <- reactive({
    economics %>%
      filter(date >= input$dateRange[1] & date <= input$dateRange[2])
  })
  
  output$forecastPlot <- renderPlotly({
    data <- filtered_data()
    var <- input$variable
    months <- input$monthsAhead
    
    ts_data <- ts(data[[var]],
                  start = c(year(min(data$date)), month(min(data$date))),
                  frequency = 12)
    
    model <- ets(ts_data)
    fc <- forecast(model, h = months)
    
    future_dates <- seq(max(data$date) %m+% months(1), by = "month", length.out = months)
    forecast_df <- data.frame(
      date = future_dates,
      forecast = as.numeric(fc$mean),
      lower = fc$lower[,2],
      upper = fc$upper[,2]
    )
    
    actual_df <- data.frame(
      date = data$date,
      value = data[[var]]
    )
    
    p <- ggplot() +
      geom_line(data = actual_df, aes(x = date, y = value), color = "blue", size = 1.2) +
      geom_line(data = forecast_df, aes(x = date, y = forecast), color = "black", linetype = "dashed") +
      geom_ribbon(data = forecast_df, aes(x = date, ymin = lower, ymax = upper), fill = "gray70", alpha = 0.3) +
      labs(title = paste("Forecast for:", var),
           x = "Date", y = var) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Value boxes
  output$latestValueBox <- renderValueBox({
    data <- filtered_data()
    latest_value <- tail(data[[input$variable]], 1)
    
    valueBox(
      value = round(latest_value, 2),
      subtitle = paste("Latest", input$variable),
      icon = icon("calendar-check"),
      color = "blue"
    )
  })
  
  output$averageValueBox <- renderValueBox({
    data <- filtered_data()
    avg_value <- mean(data[[input$variable]], na.rm = TRUE)
    
    valueBox(
      value = round(avg_value, 2),
      subtitle = paste("Average", input$variable),
      icon = icon("chart-bar"),
      color = "purple"
    )
  })
  
  output$trendDirectionBox <- renderValueBox({
    data <- filtered_data()
    n <- nrow(data)
    
    if (n < 2) {
      valueBox("N/A", "Trend Direction", icon = icon("exclamation-triangle"), color = "red")
    } else {
      first_val <- data[[input$variable]][1]
      last_val <- data[[input$variable]][n]
      diff <- last_val - first_val
      
      trend <- ifelse(abs(diff) < 0.01, "Flat",
                      ifelse(diff > 0, "Upward", "Downward"))
      color <- ifelse(trend == "Upward", "green",
                      ifelse(trend == "Downward", "red", "yellow"))
      icon_type <- ifelse(trend == "Upward", "arrow-up",
                          ifelse(trend == "Downward", "arrow-down", "arrows-left-right"))
      
      valueBox(
        value = trend,
        subtitle = paste("Trend in", input$variable),
        icon = icon(icon_type),
        color = color
      )
    }
  })
  
  output$percentChangeBox <- renderValueBox({
    data <- filtered_data()
    if (nrow(data) < 2) {
      valueBox("Not enough data", "Change", icon = icon("exclamation-triangle"), color = "red")
    } else {
      first_value <- data[[input$variable]][1]
      last_value <- data[[input$variable]][nrow(data)]
      percent_change <- ((last_value - first_value) / first_value) * 100
      box_color <- ifelse(percent_change >= 0, "green", "red")
      icon_type <- ifelse(percent_change >= 0, "arrow-up", "arrow-down")
      
      valueBox(
        value = paste0(round(percent_change, 2), "%"),
        subtitle = paste("Change in", input$variable),
        icon = icon(icon_type),
        color = box_color
      )
    }
  })
  
  output$predictedValuesTable <- renderDataTable({
    data <- filtered_data()
    selected_var <- input$variable
    
    data$time <- as.numeric(data$date)
    model <- lm(data[[selected_var]] ~ time, data = data)
    
    data$predicted_values <- predict(model)
    predicted_data <- data %>%
      select(date, actual = selected_var, predicted_values) %>%
      tail(input$monthsAhead)
    
    datatable(predicted_data, options = list(pageLength = 6))
  })
  
  output$scatterPlot <- renderPlotly({
    data <- filtered_data()
    
    p <- ggplot(data, aes_string(x = input$xvar, y = input$yvar)) +
      geom_point(color = "darkblue", alpha = 0.6) +
      theme_minimal() +
      labs(
        title = paste("Scatter Plot:", input$yvar, "vs", input$xvar),
        x = input$xvar,
        y = input$yvar
      )
    
    ggplotly(p)
  })
  
  output$correlationPlot <- renderPlot({
    data <- filtered_data()
    numeric_data <- data %>% select(pce, pop, psavert, uempmed, unemploy)
    
    corr_matrix <- cor(numeric_data, use = "complete.obs")
    corr_df <- as.data.frame(as.table(corr_matrix))
    names(corr_df) <- c("Var1", "Var2", "Correlation")
    
    ggplot(corr_df, aes(Var1, Var2, fill = Correlation)) +
      geom_tile(color = "white") +
      scale_fill_gradient2(
        low = "darkblue", mid = "white", high = "darkred",
        midpoint = 0, limit = c(-1, 1), name = "Correlation"
      ) +
      theme_minimal() +
      labs(title = "Correlation Between Economic Variables")
  })
}
# Run the app
shinyApp(ui = ui, server = server)
