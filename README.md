# 🌱 Bhoomise – Flutter Clean Architecture (GetX) + Laravel + MySQL

## 📌 Overview

Bhoomise is a scalable Flutter application built using **GetX + Clean Architecture** with **Laravel API + MySQL** as the primary backend.

The app is structured to keep:

* **Presentation Layer** clean (UI only)
* **Domain Layer** pure (business logic)
* **Data Layer** responsible for API + models

---

## 🏗️ Tech Stack

### Frontend

* Flutter
* GetX
* Clean Architecture
* Dio (API client)
* SharedPreferences / Secure Storage

### Backend

* PHP Laravel
* MySQL
* Laravel Sanctum / JWT
* REST API

---

## 🎯 Core Principles

* UI never calls APIs directly.
* Controllers use UseCases only.
* Domain layer has no Flutter / Dio imports.
* Data layer handles API responses and mapping.
* App remains scalable and maintainable.

---

## 👥 User Roles

### Customer

* Guest browsing
* Add to cart
* OTP/Login at checkout
* Track orders

### Store / Retailer

* Manage inventory
* Low stock alerts
* Assigned orders

### Admin / Supplier

* Manage products
* Manage variants
* Upload images
* Coupons
* Reports & control panel

---

## 🔄 Architecture Flow

```text
Presentation → Domain ← Data
```

---

## 📂 Project Structure

```text
lib/
│── app/
│   ├── routes/
│   ├── theme/
│   ├── bindings/
│   └── app.dart
│
│── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── dio_provider.dart
│   │
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   ├── helpers/
│   │   ├── storage_helper.dart
│   │   ├── session_helper.dart
│   │   └── validators.dart
│   │
│   ├── widgets/
│   └── values/
│       ├── colors.dart
│       ├── strings.dart
│       └── constants.dart
│
│── features/
│   ├── auth/
│   ├── home/
│   ├── product/
│   ├── cart/
│   ├── order/
│   ├── profile/
│   ├── address/
│   ├── splash/
│   └── navigation/
│
│── main.dart
```

---

## 📦 Feature Structure Example

```text
features/auth/
│── data/
│   ├── models/
│   ├── datasource/
│   └── repositories_impl/
│
│── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
│── presentation/
│   ├── controller/
│   ├── pages/
│   ├── widgets/
│   └── binding/
```

---

## 🔐 Authentication

Handled via Laravel backend:

* Phone OTP
  n- Email Login
* Sanctum / JWT Token

Store token using:

* SharedPreferences
* Flutter Secure Storage

---

## 🌐 API Rules

* All APIs inside `core/api/`
* Use Dio interceptors for tokens
* Handle errors globally
* No API logic inside UI

---

## 🧠 Common Use Cases

* LoginUser
* RegisterUser
* GetProducts
* GetProductDetails
* AddToCart
* ApplyCoupon
* CreateOrder
* GetOrders
* UpdateProfile

---

## 🔗 Deep Links

```text
myapp://product/5
myapp://order/88
myapp://coupon/SAVE50
```

---

## 🚀 Goals

* Production Ready
* Scalable Codebase
* Team Friendly
* Easy Testing
* Fast Development
* Laravel Ready Backend

---

## 💎 Recommended Setup

### Flutter Packages

```yaml
dependencies:
  get:
  dio:
  shared_preferences:
  flutter_secure_storage:
```

---

## 👨‍💻 Author

Bhoomise Tech
