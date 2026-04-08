# Karate API Testing Suite

## Overview

Automated API testing suite for the [Automation Exercise API](https://automationexercise.com) using **Karate DSL** and **Maven**.

**Status:** ✅ IMPLEMENTED (SPEC-001)

## Features

- ✅ Complete CRUD operations (Create, Read, Update, Delete)
- ✅ Sequential scenario execution with state management
- ✅ Unique data generation (timestamp-based)
- ✅ Comprehensive error path validation
- ✅ HTML report generation
- ✅ Tag-based scenario filtering (@smoke, @cleanup, etc.)
- ✅ Reusable helper utilities for assertions and data generation

## Project Structure

```
karate-api-testing/
├── pom.xml                              # Maven configuration
├── README.md                            # This file
└── src/test/java/
    ├── karate-config.js                 # Global Karate configuration
    ├── logback-test.xml                 # Logging configuration
    ├── users/
    │   ├── users.feature                # CRUD test scenarios
    │   ├── valid-user-data.json         # Test data
    │   └── UsersRunner.java             # JUnit 5 runner
    └── common/
        ├── helpers.js                   # Utility functions
        └── data.js                      # Test data sets
```

## Prerequisites

- **Java 17+**
- **Maven 3.6+**
- **Network access** to https://automationexercise.com

## Installation

1. Clone or navigate to the project directory:
   ```bash
   cd karate-api-testing
   ```

2. Verify Maven is installed:
   ```bash
   mvn --version
   ```

## Running Tests

### Execute all scenarios
```bash
mvn test
```

### Run only @smoke tests (happy paths)
```bash
mvn test -Dkarate.options="--tags @smoke"
```

### Run only @cleanup scenarios (deletion)
```bash
mvn test -Dkarate.options="--tags @cleanup"
```

### Run error path validation
```bash
mvn test -Dkarate.options="--tags @error-path"
```

### Run with specific environment
```bash
mvn test -Dkarate.env=prod
```

## Test Scenarios

### 1. CREATE — Register New User Account
- **Tag:** `@create @smoke @happy-path`
- **Endpoint:** `POST /api/createAccount`
- **Validates:** HTTP 200, responseCode 201, success message
- **Captures:** Email and password for subsequent operations

### 2. CREATE — Duplicate Account Rejection
- **Tag:** `@create @error-path`
- **Endpoint:** `POST /api/createAccount` (duplicate attempt)
- **Validates:** HTTP 200, responseCode ≠ 201, duplicate error message

### 3. READ — Get User Details
- **Tag:** `@read @smoke @happy-path`
- **Endpoint:** `GET /api/getUserDetailByEmail?email={email}`
- **Validates:** User object exists, all fields match created data
- **Captures:** Retrieved user data

### 4. READ — Email Not Found
- **Tag:** `@read @error-path`
- **Endpoint:** `GET /api/getUserDetailByEmail` (non-existent email)
- **Validates:** HTTP 200, responseCode ≠ 200, "not found" message

### 5. UPDATE — Modify User Details
- **Tag:** `@update @smoke`
- **Endpoint:** `PUT /api/updateAccount`
- **Validates:** HTTP 200, responseCode 200, update success
- **Verifies:** Changes persisted via subsequent GET call

### 6. DELETE — Remove Account
- **Tag:** `@delete @cleanup @happy-path`
- **Endpoint:** `DELETE /api/deleteAccount`
- **Validates:** HTTP 200, responseCode 200, deletion success
- **Verifies:** Account no longer retrievable via GET

### 7. DELETE — Non-existent Account
- **Tag:** `@delete @error-path`
- **Endpoint:** `DELETE /api/deleteAccount` (invalid account)
- **Validates:** HTTP 200, responseCode ≠ 200, error message

## Test Reports

Reports are automatically generated after each test run in:
```
target/karate-reports/
```

Open `target/karate-reports/karate-summary.html` in a browser to view detailed results.

## Configuration

### karate-config.js

Global configuration including:
- **Base URL:** `https://automationexercise.com/api`
- **Timeouts:** 30 seconds (read & connect)
- **Timestamp & UUID:** Auto-generated for unique data

### Data Sets

Test data is externalized in `valid-user-data.json`:
- Email, password, name, address, phone, etc.
- All required fields for the API
- Updated variants for UPDATE scenarios

## Helper Functions (common/helpers.js)

### Data Generation
- `randomEmail(domain)` — Generate unique email with timestamp
- `randomPassword()` — Generate valid password
- `generateUniqueUserData()` — Complete user dataset

### Assertions
- `assertCreateSuccess(response)` — Validate CREATE response
- `assertGetSuccess(response, email)` — Validate GET response
- `assertUpdateSuccess(response)` — Validate UPDATE response
- `assertDeleteSuccess(response)` — Validate DELETE response
- `assertUserNotFound(response)` — Validate error responses

## Execution Flow

Tests execute sequentially to maintain state:

```
1. CREATE new account
   ↓ (captures email/password)
2. READ user details
   ↓ (verifies data consistency)
3. UPDATE user name/firstname
   ↓ (verifies persistence)
4. DELETE account
   ↓ (verifies removal)
5. Subsequent READ confirms deletion
```

## Tag-Based Filtering

| Tag | Purpose | Command |
|---|---|---|
| `@smoke` | Minimal viable tests (happy paths) | `--tags @smoke` |
| `@happy-path` | Successful operations | `--tags @happy-path` |
| `@error-path` | Error scenarios & validation | `--tags @error-path` |
| `@cleanup` | DELETE operations | `--tags @cleanup` |
| `@critico` | Critical business flows | `--tags @critico` |
| `@validacion` | Validation rules | `--tags @validacion` |

## Logging

Logs are captured in:
- **Console:** Real-time output during test execution
- **File:** `target/karate.log` — Complete execution log

All requests, responses, and assertions are logged for debugging.

## Troubleshooting

### Tests time out
- Increase timeout in `karate-config.js`
- Verify network access to automationexercise.com

### Email already exists
- Each execution generates unique emails with timestamp
- If tests fail mid-run, old data may persist
- Run `@cleanup` tag to delete orphaned accounts: `mvn test -Dkarate.options="--tags @cleanup"`

### Response code mismatches
- Verify the actual API response: check logs in `target/karate.log`
- API may have changed response codes or message format
- Update `users.feature` and/or assertions accordingly

## API Reference

| Operation | Method | Endpoint | Params | Returns |
|---|---|---|---|---|
| Create | POST | `/api/createAccount` | form fields | responseCode, message |
| Get | GET | `/api/getUserDetailByEmail` | email (query) | user object |
| Update | PUT | `/api/updateAccount` | form fields | responseCode, message |
| Delete | DELETE | `/api/deleteAccount` | form fields | responseCode, message |

## Status

- **Created:** 2026-03-26
- **Last Updated:** 2026-03-26
- **Spec:** SPEC-001 (APPROVED)
- **Author:** QA Agent + Backend Developer

---

**Generated as part of ASDD workflow (Spec → Implementation → Tests → QA)**
