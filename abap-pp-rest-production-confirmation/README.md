# **SAP PP Production Confirmation – Inbound REST API (ABAP OOP)**

This repository provides a **clean, reusable ABAP REST API** for posting **SAP PP (Production Planning) order confirmations** using modern OOP design patterns.

It is built for educational & integration reference, without any company-specific logic.
All object names, variables, and mappings are intentionally generic for safe public usage.

---

## 🧩 **What This API Does**

* Exposes an **inbound REST API** over **SICF** (`/sap/bc/zpp_conf_rest`)
* Accepts **JSON** payload with one or more confirmation items
* Validates fields and processes confirmations
* Calls **SAP PP BAPI** (`BAPI_PRODORDCONF_CREATE_HDR`) through a dedicated adapter class
* Returns a structured **JSON response** with per-order success/error results
* Uses a clear multi-layer architecture

---

# 🏛️ **High-Level Architecture**

```
Client (External System / Mobile / MES)
               |
               v
    SICF HTTP Handler (ZCL_PP_CONF_HTTP_HANDLER)
               |
               v
    Application Service (ZCL_PP_CONF_APPLICATION)
               |
               v
        BAPI Adapter (ZCL_PP_CONF_BAPI_ADAPTER)
               |
               v
         SAP BAPI_PRODORDCONF_*
               |
               v
           SAP PP Order
```

### Responsibilities

| Component               | Purpose                                                  |
| ----------------------- | -------------------------------------------------------- |
| **HTTP Handler**        | Reads HTTP request, handles POST, returns JSON           |
| **Application Service** | Validation, orchestrates BAPI calls, builds API response |
| **BAPI Adapter**        | Encapsulates all SAP BAPI calls & mapping                |
| **JSON Helper**         | Converts JSON ↔ ABAP using `/UI2/CL_JSON`                |
| **Exception Class**     | Clean error handling                                     |
| **Interface**           | Shared DTO types                                         |

---

# 🌐 **API Endpoint (ICF Node)**

After activating the handler class, the API is exposed at:

```
POST /sap/bc/zpp_conf_rest
Content-Type: application/json
```

**Only POST is supported.**

### Example cURL call:

```bash
curl -X POST \
  https://your-sap-host:port/sap/bc/zpp_conf_rest \
  -H "Content-Type: application/json" \
  -d @request.json \
  -u USER:PASSWORD
```

---

# 📥 **Sample JSON Request**

```json
{
  "confirmations": [
    {
      "order_number": "100001",
      "operation_number": "0010",
      "suboperation": "",
      "plant": "1000",
      "work_center": "WC01",
      "posting_date": "2025-11-28",
      "yield_quantity": 120,
      "scrap_quantity": 2,
      "unit_of_measure": "PC",
      "confirmed_by": "PPUSER",
      "user_reference": "MOBILE_SHIFT_A",
      "confirmation_text": "Shift A output"
    }
  ]
}
```

---

# 📤 **Sample JSON Response**

### ✔️ Successful posting

```json
{
  "response": {
    "overallStatus": "OK",
    "results": [
      {
        "orderNumber": "100001",
        "operationNumber": "0010",
        "status": "SUCCESS",
        "message": "Confirmation posted successfully",
        "confirmationId": "50001234"
      }
    ]
  }
}
```

---

### ❗ Error example (from BAPI)

```json
{
  "response": {
    "overallStatus": "FAILED",
    "results": [
      {
        "orderNumber": "100001",
        "operationNumber": "0010",
        "status": "ERROR",
        "message": "Operation 0010 not found in order 100001",
        "confirmationId": ""
      }
    ]
  }
}
```

---

### 🔀 Partial success example

```json
{
  "response": {
    "overallStatus": "PARTIAL",
    "results": [
      {
        "orderNumber": "100001",
        "operationNumber": "0010",
        "status": "SUCCESS",
        "message": "Confirmation posted successfully",
        "confirmationId": "50005678"
      },
      {
        "orderNumber": "100002",
        "operationNumber": "0020",
        "status": "ERROR",
        "message": "Yield quantity missing"
      }
    ]
  }
}
```

---

# 🧱 **Main ABAP Objects in This Repository**

| Object                     | Type            | Role                               |
| -------------------------- | --------------- | ---------------------------------- |
| `ZCL_PP_CONF_HTTP_HANDLER` | Class           | Entry point for SICF REST service  |
| `ZCL_PP_CONF_APPLICATION`  | Class           | Core business logic / orchestrator |
| `ZCL_PP_CONF_BAPI_ADAPTER` | Class           | BAPI wrapper for confirmations     |
| `ZCL_PP_CONF_JSON_HELPER`  | Class           | JSON serialization/deserialization |
| `ZIF_PP_CONF_TYPES`        | Interface       | Shared type definitions (DTOs)     |
| `ZCX_PP_CONF_ERROR`        | Exception Class | API error handling                 |

---

# 🧠 **Design Principles Used**

✔ Clean ABAP layering
✔ Single Responsibility Principle (SRP)
✔ API-safe DTOs via interface
✔ Centralized exception class
✔ Decoupled BAPI adapter for easy replacement
✔ Testable architecture
✔ JSON abstraction layer
✔ Ready for future extension (goods movements, time tickets, serials)

---

# 🔧 **Installation Steps**

### 1. Create these classes/interfaces in SE24

* Paste each `.abap` file into your SAP system

### 2. Create an SICF service

Path example:

```
default_host → sap → bc → zpp_conf_rest
```

Inside the node, maintain:

| Parameter         | Value                        |
| ----------------- | ---------------------------- |
| **Handler Class** | `ZCL_PP_CONF_HTTP_HANDLER`   |
| **Logon**         | Required (Basic Auth or SSO) |

Activate the ICF node.

### 3. Test using Postman, VS Code Thunder Client, or cURL

---

# 🔍 **Why This Repo Exists**

Most SAP PP confirmation integrations are:

* tightly coupled
* procedural
* hard-coded
* not API-ready

This project demonstrates how to build a **clean, modern, REST-based integration** using **pure ABAP OOP**, suitable for MES, mobile apps, and IoT production systems.

---

# 📄 **License**

MIT License – free to use, modify, and build upon.

---

# 🤝 Contributing

Pull requests and enhancements are welcome!
You can add:

* Time ticket confirmations
* Goods movement extension
* PDC/MES integration examples
* RAP/OData version
* Unit tests with ABAP Test Double Framework
