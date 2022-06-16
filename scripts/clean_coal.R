# script for cleaning coal data

# Author: pedro
# Version: 2022-06-15

# Packages
library(tidyverse)
library(janitor)
library(GGally)

# Parameters

  # input
file_raw <- here::here("data/coal_data.rds")
  # output
file_out <- here::here("data/clean_coal.rds")
# ============================================================================

# Code
coal_df <- read_rds(file_raw)

coal_df |>
  skimr::skim()

# additional info
# EG.ELC.COAL.ZS - Electricity production from coal sources (% of total)
# EG.ELC.FOSL.ZS - Electricity production from oil, gas and coal sources (% of total)
# EG.USE.COMM.FO.ZS - Fossil fuel energy consumption (% of total)
# NY.GDP.COAL.RT.ZS - Coal rents (% of GDP)
# NW.NCA.SACO.TO - Natural capital, subsoil assets: coal (constant 2014 US$) - Natural capital includes the valuation of fossil fuel energy (oil, gas, hard and soft coal) and minerals (bauxite, copper, gold, iron ore, lead, nickel, phosphate, silver, tin, and zinc), agricultural land (cropland and pastureland), forests (timber and some nontimber forest products), and protected areas.  Values are measured at market exchange rates in constant 2014 US dollars, using a country-specific GDP deflator.


# 270111 -  Coal; anthracite, whether or not pulverised, but not agglomerated
# 270112 - Coal; bituminous, whether or not pulverised, but not agglomerated
# 270119 - Coal; (other than anthracite and bituminous), whether or not pulverised but not agglomerated


# clean the data

coal_df |>
  clean_names() |>
  select(year,
         reporter_iso,
         partner_iso,
         commodity_code,
         trade_value_usd_imp,
         trade_value_usd_exp,
         commodity_fullname_english,
         ny_gdp_coal_rt_zs,
         nw_nca_saco_to) |>
  rename(
    coal_rent_pct_of_gdp = ny_gdp_coal_rt_zs,
    natural_capital = nw_nca_saco_to,
    commodity = commodity_fullname_english
  ) |>
  mutate(commodity = case_when(
    str_detect(commodity_code, "270111") ~ "anthracite",
    str_detect(commodity_code, "270112") ~ "bituminous",
    str_detect(commodity_code, "270119") ~ "other"
  )) |>
  select(-commodity_code) |> # drop the commodity code
  arrange(year) |>
  mutate(trade_id = row_number()) |>
  select(trade_id,everything()) |>
  pivot_longer(cols = starts_with("trade_value_"),
               names_to = "trade",
               values_to = "value_usd",
               names_prefix = "trade_value_usd_") |>
  mutate(trade = as_factor(trade),
         value_usd = value_usd + 0.01) |>
  na.omit() |>  # drop rows with missing variables
  write_rds(file_out)



