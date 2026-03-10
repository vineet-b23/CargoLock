# 🚚 CargoLock: AI-Driven Dispute Verification & Blockchain Escrow

CargoLock is a high-fidelity logistics security platform designed to eliminate "he-said, she-said" disputes in cargo delivery. By combining **Groq LPU** for real-time image verification and **Ethereum (Sepolia)** for trustless payments, we ensure every delivery is verified before funds are released.

## 🚀 Key Features (Review 2 Progress)

### 1. Multi-Role Terminal System
A robust Role-Based Access Control (RBAC) system implemented via a secure interface:
* **Supplier:** Initialize dispatches and monitor cargo health.
* **Admin:** Manage the driver pool and assign orders based on **Reputation Grade (S/A/B)**.
* **Driver:** High-security terminal with integrated AI photo verification.
* **Customer:** Secure payment portal with integrated **Sepolia ETH Gateway**.

### 2. AI Image Verification (Sentinel Engine)
* **Groq LPU Integration:** Powered by Groq for ultra-low latency verification.
* **Automated Resolution:** Compares cargo state at pickup vs. delivery to resolve disputes instantly.
* **Exif Validation:** Prevents fraud by validating metadata to block "old photo" uploads.

### 3. Blockchain Escrow Integration
* **Smart Contracts:** Payments are held on the **Sepolia Testnet**.
* **Trustless Release:** Funds are released automatically only upon successful AI verification.
* **Vercel Gateway:** Direct redirection from the mobile app to a hosted payment gateway.

## 🛠️ Technical Stack

| Component | Technology |
| :--- | :--- |
| **Mobile Frontend** | Flutter (Dart) |
| **Web Gateway** | React.js, Tailwind CSS |
| **Backend** | Node.js, Express, PostgreSQL/Prisma |
| **AI Engine** | Groq LPU API (Llama 3) |
| **Blockchain** | Solidity, Sepolia Testnet, ethers.js v6 |

## 🚀 API Endpoints
The backend manages the following 6 core logic routes:
* `POST /order/create` - Initialize dispatch metadata.
* `POST /order/assign-driver` - Admin assignment based on Reputation Grade.
* `POST /order/submit-proof` - Driver upload for Sentinel Engine analysis.
* `POST /order/confirm` - Customer receipt and fund release trigger.
* `POST /order/dispute` - Flagging for manual admin review.
* `POST /order/resolve` - Final settlement and reputation update.

## 📥 Installation & Setup

### 1. Prerequisites
* Flutter SDK (v3.0.0+)
* Node.js (v18.0.0+)
* MetaMask with Sepolia ETH.

### 2. Setup Instructions
```bash
# Clone the Repository
git clone [https://github.com/vineet-b23/CargoLock.git](https://github.com/vineet-b23/CargoLock.git)

# Setup Backend
cd backend
npm install
npx prisma migrate dev

# Setup Mobile Terminal
cd cargolock
flutter pub get
flutter run
