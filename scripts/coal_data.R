# script to download coal data from worldbank and ITC databases

# Author: Peter Boshe
# Version: 2022-06-12

# Packages
library(wbstats)
library(tidyverse)
library(tradestatistics)

# Parameters

# ============================================================================



# inspect our worldbank indicators
wb_search("coal") |> view()

# EG.ELC.COAL.ZS - Electricity production from coal sources (% of total)
# EG.ELC.FOSL.ZS - Electricity production from oil, gas and coal sources (% of total)
# EG.USE.COMM.FO.ZS - Fossil fuel energy consumption (% of total)
# NY.GDP.COAL.RT.ZS - Coal rents (% of GDP)
# NW.NCA.SACO.TO - Natural capital, subsoil assets: coal (constant 2014 US$) - Natural capital includes the valuation of fossil fuel energy (oil, gas, hard and soft coal) and minerals (bauxite, copper, gold, iron ore, lead, nickel, phosphate, silver, tin, and zinc), agricultural land (cropland and pastureland), forests (timber and some nontimber forest products), and protected areas.  Values are measured at market exchange rates in constant 2014 US dollars, using a country-specific GDP deflator.

tz_coal_wb_df <- wb_data(
  indicator = c("EG.ELC.COAL.ZS",
                "EG.ELC.FOSL.ZS",
                "EG.USE.COMM.FO.ZS",
                "NY.GDP.COAL.RT.ZS",
                "NW.NCA.SACO.TO"),
  country = "tza",
  start_date = 2002,
  end_date = 2020
)



# inspect our ots

ots_tables |> view()
ots_commodities |> view()
# 270111 -  Coal; anthracite, whether or not pulverised, but not agglomerated
# 270112 - Coal; bituminous, whether or not pulverised, but not agglomerated
# 270119 - Coal; (other than anthracite and bituminous), whether or not pulverised but not agglomerated

ots_country_code("Tanzania")
tz_coal_trade_df <- ots_create_tidy_data(years = c(2002:2020), # data only available from 2002 to 2020
                     reporters = "tza",
                     commodities = c("270111", "270112", "270119"),
                     table = "yrpc",
                     max_attempts = 10)


# cleaning our wb data
tz_coal_wb_df <- tz_coal_wb_df |>
  mutate_if(is.character,str_to_lower) |>
  select(-iso2c)

# filtering,joining and exporting dataset

  tz_coal_trade_df |>
  filter(partner_iso != "all") |>
  left_join(ots_commodities, by = "commodity_code") |> #add commodity descriptions
  select(year,
         reporter_iso,
         partner_iso,
         commodity_code,
         trade_value_usd_imp,
         trade_value_usd_exp,
         commodity_fullname_english) |>
    left_join(tz_coal_wb_df, by = c("year" = "date")) |> # join with world bank data
    write_rds("~/Projects/worldbank_itc_projects/data/coal_data.rds") # save the data


























