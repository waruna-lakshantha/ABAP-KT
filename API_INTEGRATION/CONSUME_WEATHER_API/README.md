# **Open-Meteo Weather API Integration in ABAP (OOP + JSON + Clean Architecture)**

*A practical ABAP example for consuming external REST APIs using clean, reusable design patterns.*

---

## 🌤️ Overview

This repository contains a complete ABAP implementation for consuming the **Open-Meteo Weather API** and storing weather snapshots inside SAP using **OOP-based clean architecture**.

The goal of this project is to show how simple and maintainable external API integrations can be when you use a proper design pattern:

* ✔ Strategy Pattern (API Provider)
* ✔ Repository Pattern (DB access)
* ✔ Service Layer (Business orchestration)
* ✔ Clean typed JSON deserialization
* ✔ Reusable HTTP Authentication helper (for future secured APIs)

Open-Meteo is **free**, requires **no authentication**, and provides clear JSON responses — making it perfect for ABAP developers to practice consuming REST APIs.

---

## 🚀 Features

* Fetch live weather data from Open-Meteo
* Parse JSON using `/UI2/CL_JSON`
* Convert timestamp from ISO8601 → ABAP DATS/TIMS
* Save snapshots to a custom table (`ZWEATHER_SNAP`)
* Clean, extensible OOP design
* Ready for:

  * RAP / OData exposure
  * Fiori List Report
  * Background jobs (SM36)
  * Multi-provider architecture
* Includes reusable HTTP Basic + Bearer token helper class

---

## 📦 Project Structure

```
src/
│
├── zif_weather_provider.intf.abap
├── zcl_weather_open_meteo.clas.abap
├── zcl_weather_repository.clas.abap
├── zcl_weather_app_service.clas.abap
├── zcl_http_auth_helper.clas.abap
└── zweather_collector.prog.abap
```

---

## 🧱 Z-Table Structure (ZWEATHER_SNAP)

Suggested table fields:

| Field                | Description           |
| -------------------- | --------------------- |
| LOCATION_ID          | Logical location name |
| OBS_DATE             | Observation date      |
| OBS_TIME             | Observation time      |
| LATITUDE / LONGITUDE | Coordinates           |
| TEMP_C               | Temperature           |
| WINDSPEED            | Wind speed            |
| WINDDIR              | Wind direction        |
| WEATHERCODE          | Weather code          |
| IS_DAY               | X / blank             |
| CREATED_ON / BY      | Audit keys            |

DDL example is included inside the SAP Community article & `/src`.

---

## 📡 API Used (Open-Meteo)

Open-Meteo endpoint used:

```
https://api.open-meteo.com/v1/forecast?latitude=<LAT>&longitude=<LON>&current_weather=true
```

Example:

```
https://api.open-meteo.com/v1/forecast?latitude=6.9271&longitude=79.8612&current_weather=true
```

Why use Open-Meteo?

* 100% free
* No API keys
* Simple JSON
* Stable & fast
* Perfect for teaching and prototyping

---

## 🧩 ABAP Architecture

This project uses a clean layered architecture:

```
Report → Service Layer → Provider (HTTP + JSON)
                      → Repository (DB insert/update)
```

### **1. Provider (Strategy Pattern)**

Handles HTTP call + JSON parsing.

### **2. Repository**

Stores weather snapshot in SAP table.

### **3. Service Layer**

Coordinates provider + repository.

### **4. Executable Report**

Triggers the API call using parameters.

This makes the project easy to extend.
Tomorrow, you can add providers such as:

* OpenWeatherMap
* WeatherAPI.com
* Internal REST APIs
* BTP services

without changing any business logic.

---

## 🧪 Example: Run the Collector Report

Program: `ZWEATHER_COLLECTOR`

```abap
REPORT zweather_collector.

PARAMETERS:
  p_lat TYPE decfloat16 DEFAULT '6.9271' OBLIGATORY,
  p_lon TYPE decfloat16 DEFAULT '79.8612' OBLIGATORY,
  p_loc TYPE zweather_snap-location_id DEFAULT 'COLOMBO' OBLIGATORY.

DATA lo_service TYPE REF TO zcl_weather_app_service.

START-OF-SELECTION.

  lo_service = NEW zcl_weather_app_service(
                 io_provider = NEW zcl_weather_open_meteo( )
                 io_repo     = NEW zcl_weather_repository( ) ).

  TRY.
      lo_service->collect_and_save(
        iv_latitude  = p_lat
        iv_longitude = p_lon
        iv_location  = p_loc ).

      WRITE: / 'Weather snapshot saved for', p_loc.
    CATCH cx_root INTO DATA(lx).
      WRITE lx->get_text( ).
  ENDTRY.
```

---

## 🔐 HTTP Authentication (Reusable Helper)

Even though Open-Meteo is free, this repo includes a helper for real-world APIs:

```abap
zcl_http_auth_helper=>set_basic_auth( lo_http_client, 'user', 'pass' ).

zcl_http_auth_helper=>set_bearer_auth( lo_http_client, 'jwt-token' ).
```

Useful for:

* OpenWeatherMap
* Government APIs
* Azure / AWS endpoints
* BTP destinations
* IoT gateways

---

## 🌟 Why This Pattern Is Useful

### ✔ Works in SAP ECC & S/4HANA

Including on-premise versions.

### ✔ Pro-level OOP structure

Makes the integration future-proof.

### ✔ Perfect for knowledge transfer

Great for onboarding, internal KT, or community sharing.

### ✔ Easy to extend

Create `ZCL_WEATHER_<ANY_PROVIDER>` and reuse the same service + repo.

### ✔ Prepare for RAP & ABAP Cloud

Layered architecture fits into modern ABAP development.

### ✔ Demonstrates JSON consumption cleanly

No manual parsing — pure object mapping.

---

## 🛠️ How to Install

1. Create table `ZWEATHER_SNAP`
2. Import all classes from `/src`
3. Activate the interface + classes + report
4. Run the report:

```
ZWEATHER_COLLECTOR
```

5. Enter:

* Latitude
* Longitude
* Location ID

6. Check data in table `ZWEATHER_SNAP`

---

## 📈 Real-World Usage Ideas

You can use this pattern for:

* IoT data ingestion
* Climate-based logistics planning
* Production shift adjustments
* Route optimization
* Energy management dashboards
* Any REST API inside SAP

This repository is not only a weather demo — it’s a **general-purpose API integration blueprint**.

---

## 🤝 Contributions

Feel free to:

* Fork the project
* Add new providers
* Improve error handling
* Add unit tests
* Add RAP behavior / UI
* Provide sample ALV reports

Pull requests are welcome!

---

## 📚 Related Articles

* **SAP Community Article:** *Consuming the Open-Meteo API Using ABAP (Full Guide)*
* **Upcoming:** *Calling Secured REST APIs (Basic + Token) in ABAP*
* **Upcoming:** *Building a Fiori List Report for Weather Snapshots*

---

## ⭐ Star This Repository

If this project helped you learn ABAP API integration
➡️ please **star** ⭐ the repository.

It helps other developers find this free KT material
and supports the ABAP community.
