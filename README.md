# 🚀 SmartPOS AI

**SmartPOS AI** is an intelligent Point of Sale system built with **Flutter**, powered by **Firebase**, **GetX** for state management, and **Gemini AI** for advanced business insights.

It simplifies inventory and sales management while giving AI-powered suggestions based on your sales, profit/loss, and stock data.

---

## 🧠 Features

- 📦 Inventory Management  
- 💰 Sales Tracking  
- 📊 Profit/Loss Analysis with Graphs  
- 🧾 Downloadable Profit/Loss Reports (PDF)  
- 🤖 AI Suggestions (powered by Gemini API)  
- 🔍 AI analyzes sales, inventory & profit/loss and gives intelligent business insights  

---

## 🛠 Tech Stack

- **Flutter** – Cross-platform app development  
- **Firebase** – Authentication, Firestore, Storage  
- **GetX** – Reactive state management & routing  
- **Gemini API** – AI for smart sales & inventory suggestions

---

## 📸 Screenshots

| Splash | Product Screen | Add Product |
|--------|----------------|-------------|
| ![Splash](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.07_89b8eada.jpg) | ![Product Screen](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.08_e6648e50.jpg) | ![Add Product](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.08_712de721.jpg) |

| Empty Cart | Cart with Product | Sales Section |
|------------|-------------------|----------------|
| ![Empty Cart](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.08_b225688d.jpg) | ![Cart](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.09_cc822c9a.jpg) | ![Sales](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.09_e208876f.jpg) |

| Profit & Loss | Graph View | AI Suggestions |
|----------------|------------|----------------|
| ![Profit Loss](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.10_5138f843.jpg) | ![Graph](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.10_2733227f.jpg) | ![AI Suggestion](https://raw.githubusercontent.com/UsamaAbubakar1/inventory-management-app/07646b90a1e0610882cc6e23cf92b95b887bc8f3/WhatsApp%20Image%202025-05-05%20at%2011.49.10_df0e2e59.jpg) |

> _Place screenshots in a `screenshots/` folder inside your project._

---

## 🧩 Installation Guide

Follow these steps to run the project locally:

```bash
# 1. Clone the repository
git clone https://github.com/UsamaAbubakar1/inventory-management-app.git
cd smartpos-ai

# 2. Install dependencies
flutter pub get

# 3. Connect your Firebase to the project


# 4. Add your Gemini API Key
# .env file in the root directory and add:
GEMINI_API_KEY=your_gemini_api_key_here

# 5. Run the app
flutter run
