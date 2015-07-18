## from weather data frame
weather <- load_data("./data/clean_severe_weather_events.csv")
weatherG <- weather %>% group_by(year, month, EVENT_TYPE, STATE)
weatherG <- weatherG %>% summarise_each(funs(sum(.,na.rm = TRUE)), CROPDMG, PROPDMG, FATALITIES, INJURIES, DMG)
weatherG$health_impact <- weatherG$FATALITIES + weatherG$INJURIES
write.csv(x = weatherG, file = "data/severe-weather-compact-db.csv")