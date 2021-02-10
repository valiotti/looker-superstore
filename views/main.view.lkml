view: main {
  sql_table_name: superstore.orders ;;

  # Filter options

  filter: date_filter {
    type: date
  }

  dimension_group: filter_start_date {
    type: time
    timeframes: [raw]
    sql: TIMESTAMP(NULLIF({% date_start date_filter %}, 0)) ;;
  }

  dimension_group: filter_end_date {
    type: time
    timeframes: [raw]
    sql: TIMESTAMP(NULLIF({% date_end date_filter %}, 0)) ;;
  }

  dimension: previous_start_date {
    type: date
    hidden: yes
    sql: DATE_SUB(${filter_start_date_raw}, INTERVAL 1 YEAR) ;;
  }

  dimension: previous_end_date {
    type: date
    hidden: yes
    sql: DATE_SUB(${filter_end_date_raw}, INTERVAL 1 YEAR) ;;
  }

  dimension: timeframes {
    description: "Use this field in combination with the date filter field for dynamic date filtering"
    suggestions: ["period", "previous period"]
    type: string
    case:  {
      when:  {
        sql: ${TABLE}.OrderDate BETWEEN ${filter_start_date_raw} AND ${filter_end_date_raw} ;;
        label: "Selected year"
      }
      when: {
        sql: ${TABLE}.OrderDate BETWEEN ${previous_start_date} AND ${previous_end_date} ;;
        label: "Previous year"
      }
      else: "Q"
    }
  }

  # Main fields

  dimension: month {
    type: date_month
    allow_fill: no
    sql: ${TABLE}.OrderDate ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.Region ;;
    # order_by_field: sales
  }

  dimension: province {
    type: string
    sql: ${TABLE}.Province ;;
    # order_by_field: sales
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}.ProductCategory ;;
  }

  dimension: product_subcategory {
    type: string
    sql: ${TABLE}.ProductSubCategory ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.ProductName ;;
  }

  dimension: customer_segment {
    type: string
    sql: ${TABLE}.CustomerSegment ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.CustomerName ;;
  }

  measure: profit {
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.Profit ;;
  }

  measure: profit_curr {
    type: sum
    value_format: "$#,##0"
    sql: CASE WHEN ${TABLE}.OrderDate BETWEEN ${filter_start_date_raw} AND ${filter_end_date_raw} THEN ${TABLE}.Profit ELSE NULL END ;;
  }

  measure: profit_curr_not_null {
    type: number
    sql: CASE WHEN ${TABLE}.OrderDate BETWEEN ${filter_start_date_raw} AND ${filter_end_date_raw} THEN 1 ELSE 0 END ;;
  }

  measure: profit_prev {
    type: sum
    value_format: "$#,##0"
    sql: CASE WHEN ${TABLE}.OrderDate BETWEEN ${previous_start_date} AND ${previous_end_date} THEN ${TABLE}.Profit ELSE NULL END ;;
  }

  measure: profit_prev_not_null {
    type: number
    sql: CASE WHEN ${TABLE}.OrderDate BETWEEN ${previous_start_date} AND ${previous_end_date} THEN 1 ELSE 0 END ;;
  }

  measure: sales {
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.Sales ;;
  }

  measure: orders {
    type: count_distinct
    sql: ${TABLE}.OrderID ;;
  }

  measure: discount {
    type: average
    value_format_name: percent_2
    sql: ${TABLE}.Discount ;;
  }

  measure: customers {
    type: count_distinct
    sql: ${TABLE}.CustomerName ;;
  }

  measure: sales_per_customer {
    type: number
    value_format: "$#,##0"
    sql: ${sales} / NULLIF(${customers},0) ;;
  }
}
