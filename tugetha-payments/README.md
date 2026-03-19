# Tugetha Payment Orchestration Backend (Django)

This is the authoritative backend for Tugetha's financial operations. It replaces the previous Firebase Cloud Functions logic with a secure, double-entry ledger system.

## Core Architecture
- **Django**: Handles money movement, ledger management, and Paystack integration.
- **Firebase Auth**: Used for user authentication (JWT verification in Django).
- **Firestore**: Synchronized display-only database for the Flutter UI.
- **Paystack**: M-Pesa STK push and split payment provider.

## Directory Structure
- `apps/ledger`: Double-entry accounting system.
- `apps/payments`: Paystack integration (Top Up, P2P Transfers).
- `apps/loans`: Secure disbursement and repayment logic.
- `apps/webhooks`: Paystack callback handlers.
- `common/authentication.py`: Firebase JWT validator.
- `common/firebase_sync.py`: One-way Django → Firestore sync.

## Setup Instructions

### 1. Environment Configuration
Create a `.env` file in this directory (a template is provided). You will need:
- `PAYSTACK_SECRET_KEY`
- `FIREBASE_CREDENTIALS_PATH` (Point to your `firebase-credentials.json` file)
- `DATABASE_URL` (PostgreSQL recommended)

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Database Migrations
```bash
python manage.py migrate
```

### 4. Run the Server
```bash
python manage.py runserver
```

### 5. Celery Worker (For background sync & tasks)
```bash
celery -A config worker -l info
```

## Security Design
- **Auth**: Every request from Flutter must include a `Bearer <Firebase_ID_Token>`.
- **Idempotency**: All financial endpoints require an `idempotency_key` to prevent duplicate processing.
- **Atomicity**: Ledger movements use `db_transaction.atomic` to ensure data integrity.
- **Facilitator Model**: Funds move directly to user subaccounts; Tugetha only takes a facilitation fee.
