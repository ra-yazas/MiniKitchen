# MiniKitchen - Restaurant Management System & Customer Web Application

MiniKitchen is a modern, responsive web application designed for artisanal restaurants. It provides a customer-facing portal with dynamic menu browsing, table reservations, and an AI-assisted conversational concierge, alongside an administrative dashboard for real-time order approvals, menu availability management, and database synchronization.

---

## 1. Technologies Used

### Frontend Architecture
- **HTML5**: Semantic markup, accessible form controls, and structured document hierarchy.
- **CSS3**: Custom properties (CSS variables), CSS Grid, Flexbox, fluid clamp typography, and responsive media queries.
- **JavaScript (ES6+)**: Vanilla JavaScript utilizing modules, async/await, Fetch API, custom events, and LocalStorage/SessionStorage persistence.
- **Font & Icon Libraries**: Font Awesome 6.5.1 and Google Fonts (Plus Jakarta Sans).

### Backend & Database
- **Supabase (PostgreSQL 15+)**: Cloud relational database engine.
- **Row-Level Security (RLS)**: Security policies restricting access control on customer data and staff records.
- **PL/pgSQL Functions**: Stored procedures for staff authentication and atomic data transactions.
- **pgcrypto Extension**: Secure password hashing using the Blowfish algorithm (`gen_salt('bf', 10)`).

### AI Integration
- **Google Gemini API**: Integration with the `gemini-1.5-flash` model via the REST endpoint for natural language query resolution, menu recommendations, and reservation parsing.
- **Local Fallback Engine**: Rule-based natural language processing engine running client-side to ensure zero downtime during network interruptions.

### Application Architecture
- **Pure Client-Side Architecture**: Zero build tools, no compilation step, and no runtime dependencies required. Runs natively in any standard web browser using CDN-delivered libraries.

---

## 2. Admin Panel Credentials

The staff management portal is accessed via `admin.html`. The system comes pre-seeded with two administrative accounts for initial configuration:

| Username | Password | Full Name | Staff Role |
| :--- | :--- | :--- | :--- |
| `admin` | `AdminPassword2026!` | Chef Niroshan | Head Chef |
| `yasasmanager` | `AdminPassword2026!` | Yasas Manager | Restaurant Manager |

### Staff Registration Passcode
To register a new staff account from the login screen, an internal authorization PIN is required:
- **Staff Security PIN**: `MINI2026`

---

## 3. Installation & Local Setup

### Prerequisites
- A modern web browser (Google Chrome, Microsoft Edge, Mozilla Firefox, or Safari).
- An optional code editor such as Visual Studio Code.

### How to Run Locally

#### Option 1: Direct Browser Launch (No Installation Required)
Because MiniKitchen is built entirely with standard web standards and loads its libraries via CDN, no software installation, package managers, or server setup are required:
1. Open the project folder in your file explorer.
2. Double-click `index.html` to open the customer website in your default browser.
3. Open `admin.html` to access the staff administration dashboard.

#### Option 2: Visual Studio Code Live Server
If you prefer running through a local development server:
1. Open the project folder in Visual Studio Code.
2. Install the **Live Server** extension if not already installed.
3. Right-click `index.html` and select **Open with Live Server**.
4. The application will open automatically at `http://127.0.0.1:5500/index.html`.

---

## 4. Environment Variables & Configuration

The application uses configuration modules located in the `js/` directory. Values can be configured directly in code or updated dynamically through the Admin Dashboard interface.

### Configuration Parameters

| Parameter Name | Storage Location | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `minikitchen_supabase_url` | Browser LocalStorage | `""` (Empty string) | Project URL for the Supabase PostgreSQL backend. |
| `minikitchen_supabase_key` | Browser LocalStorage | Configured anon key | Public / anonymous API key for Supabase access. |
| `minikitchen_gemini_api_key` | Browser LocalStorage | Configured AQ key | API key for Google Gemini generative AI calls. |
| `minikitchen_gemini_model` | Browser LocalStorage | `gemini-1.5-flash` | Target model for generative responses. |

### Configuration via Admin Dashboard
1. Open `admin.html` and log in with your staff credentials.
2. To configure Supabase: Click **Supabase: Setup Database** in the top navigation bar. Enter your Project URL and Publishable Key, then click **Save & Connect Database**.
3. To configure Gemini AI: Click **Gemini AI: Active** in the top bar. Enter or change the API key and click **Test Connection** to verify live connectivity.

---

## 5. Data Setup & Database Schema

MiniKitchen supports both local browser persistence and full PostgreSQL synchronization via Supabase.

### Database Setup Instructions

1. Log in to your **Supabase Dashboard** (`https://supabase.com`).
2. Create a new project or select an existing project.
3. In the left navigation, navigate to **SQL Editor**.
4. Open the file `supabase_schema.sql` from the project root, copy its entire contents, paste them into the SQL Editor, and execute the query.

### Database Schema Overview

The `supabase_schema.sql` script creates the following schema:

1. **`menu_items`**:
   - `id` (TEXT, Primary Key): Unique dish identifier (e.g., `MK-ITEM-1`).
   - `name` (TEXT): Dish title.
   - `category` (TEXT): Categorization (`burgers`, `pizzas`, `tacos-bites`, `bowls-noodles`, `desserts-drinks`).
   - `price` (NUMERIC): Price in Sri Lankan Rupees (Rs. LKR).
   - `image` (TEXT): URL to food imagery.
   - `description` (TEXT): Detailed culinary description and ingredients.
   - `is_available` (BOOLEAN): Current kitchen inventory availability toggle.
   - `is_vegetarian`, `is_spicy`, `is_popular` (BOOLEAN): Dietary and promotion flags.
   - `prep_time` (TEXT), `calories` (INTEGER): Nutritional attributes.

2. **`reservations`**:
   - `id` (TEXT, Primary Key): Reservation reference code (e.g., `MK-1001`).
   - `customer_name`, `email`, `phone` (TEXT): Guest contact details.
   - `date` (DATE), `time` (TEXT): Dining schedule.
   - `guests` (INTEGER): Party size (1 to 20 diners).
   - `seating_area` (TEXT): Assigned area (`Indoor Main Dining`, `Garden Terrace`, `Mezzanine Lounge`).
   - `status` (TEXT): Booking lifecycle status (`pending`, `confirmed`, `rejected`).
   - `special_notes`, `occasion` (TEXT): Customer dietary requests and celebration details.

3. **`admin_users`**:
   - `id` (UUID, Primary Key): System identifier.
   - `username`, `email` (TEXT, Unique): Credentials.
   - `full_name`, `role` (TEXT): Staff metadata.
   - `password_hash` (TEXT): Blowfish-encrypted password hash.
   - `created_at`, `last_login` (TIMESTAMPTZ): Audit timestamps.

4. **Stored Procedures**:
   - `register_admin_user(p_username, p_email, p_password, p_full_name, p_role)`: Inserts new staff records with encrypted password hashing.
   - `login_admin_user(p_username, p_password)`: Verifies credentials against the stored Blowfish hash and updates login timestamps.

---

## 6. AI Configuration

The application features **MiniChef**, an AI culinary assistant powered by the Google Gemini API.

### Technical Implementation
- **Configuration Module**: Handled in `js/gemini-config.js` via the `window.GEMINI_CONFIG` object.
- **REST Endpoint**: Communicates with `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`.
- **Supported Key Formats**: Native support for Google's latest Authentication Key format (`AQ.` prefix) as well as legacy Google Cloud API keys (`AIza` prefix).
- **Fallback Hierarchy**: The client attempts requests in sequence across `gemini-1.5-flash`, `gemini-1.5-flash-latest`, and `gemini-2.0-flash`.
- **Zero-Downtime Fallback**: If an internet outage or API rate limit occurs, the assistant routes user queries to an internal rule-based knowledge engine (`generateLocalKnowledgeResponse` in `js/chatbot.js`), ensuring uninterrupted visitor support.

### System Prompt & Context Injection
The assistant dynamically receives real-time context from the application state on every invocation:
- Real-time catalog of available menu dishes and prices in Sri Lankan Rupees (Rs. LKR).
- Live inventory statuses (dishes marked out of stock are noted immediately).
- Opening hours, parking amenities, and Colombo 03 location details.
- Dietary standards, including 100% Halal meat certifications and vegan guidelines.

---

## 7. Key Workflows

### Workflow 1: Customer Table Reservation & Tracking
1. **Submission**: The customer completes the reservation form on `index.html` or through the interactive booking card in the AI chat.
2. **Validation**: The client validates party size, selected date, lunch/dinner time slots, and contact details.
3. **Reference Generation**: A unique booking reference ID (e.g., `MK-8491`) is generated and returned to the guest.
4. **State Storage**: The record is saved to the local store and synced to the Supabase `reservations` table with status `pending`.
5. **Status Verification**: The guest can verify their booking status at any time by entering their code in the Status Tracker modal or asking the AI assistant.

### Workflow 2: AI Concierge Multi-Task Workflow
1. **Menu Inquiries**: The visitor asks about dishes, ingredients, or prices (e.g., "What are your vegetarian dishes?"). The assistant cross-references the live menu catalog and formats prices in Rs. LKR.
2. **Conversational Booking**: If a visitor states booking intent (e.g., "Book a table for 4 tomorrow at 8pm"), the assistant parses the parameters and renders an interactive confirmation card directly in the chat window.
3. **Reservation Status Verification**: If a user inputs a booking code, the assistant queries the store and displays a structured status card showing approval state and table details.
4. **Store Inquiries**: Answers queries regarding valet parking, hours, and private mezzanine event bookings.

### Workflow 3: Staff & Management Operations
1. **Authentication**: Staff members authenticate via `admin.html` with username/email and password.
2. **Reservation Approval / Rejection**: Managers review incoming requests in the Reservations table and click **Approve** or **Reject**. The status updates in the UI and synchronizes with Supabase.
3. **Menu Catalog Management**: Staff can toggle dish availability in real time. Marking an item unavailable updates the public menu catalog instantly.
4. **Menu Modifications**: Staff can create, edit, or delete dishes through the Add Food Item modal.
5. **Profile Customization**: Staff can customize their display name, role, monogram avatar color, and password via the Staff Profile Settings modal.

---

## 8. Deployment Steps

MiniKitchen is a static web application that connects directly to cloud APIs (Supabase and Gemini). It can be deployed to any static web hosting provider in minutes without needing server configuration.

### Option 1: GitHub Pages
1. Push the project files to a GitHub repository.
2. In the repository settings, navigate to **Pages**.
3. Under **Branch**, select `main` (or `master`) and folder `/ (root)`.
4. Click **Save**. The website will be published at `https://<username>.github.io/<repository-name>/`.

### Option 2: Netlify
1. Log in to Netlify (`https://www.netlify.com`).
2. Drag and drop the `Minikitchen` folder into the Netlify dashboard, OR link your GitHub repository.
3. Set **Build command** to empty and **Publish directory** to `.`.
4. Click **Deploy Site**.

### Option 3: Vercel
1. Log in to Vercel (`https://vercel.com`).
2. Click **Add New Project** and import the repository.
3. Set Framework Preset to **Other** with root directory `.`.
4. Click **Deploy**.

### Option 4: Traditional Web Hosting (cPanel / Apache / Nginx)
1. Upload all project files into your web server's public directory (e.g., `public_html`).
2. Ensure file permissions allow reading of `.html`, `.css`, and `.js` files.

---

## 9. Project Directory Structure

```
d:/Minikitchen/
├── index.html              # Customer-facing website, booking forms, and chat widget
├── admin.html              # Administrative portal for reservations and menu management
├── supabase_schema.sql     # PostgreSQL schema, table definitions, RLS, and seed data
├── README.md               # System documentation and operational reference
├── css/
│   ├── style.css           # Design tokens, color palette, typography, and base elements
│   ├── components.css      # Header, hero, food cards, categories, and footer layout
│   ├── reservations.css    # Reservation form, time slots, stepper, and confirmation cards
│   ├── chatbot.css         # Chat widget interface, message bubbles, and mobile sheet
│   ├── admin.css           # Admin sidebar, metrics, tables, switches, and modals
│   └── responsive.css      # Responsive breakpoints, drawer menus, and mobile optimizations
└── js/
    ├── gemini-config.js    # Google Gemini API key management and connection testing
    ├── supabase-config.js  # Supabase client credentials and connection state
    ├── state.js            # Central data store, LocalStorage synchronization, and event bus
    ├── app.js              # Public site controllers, menu filtering, and hours calculator
    ├── reservations.js     # Form validation, guest stepper, and status tracker modal
    ├── chatbot.js          # Conversational AI assistant and in-chat booking engine
    └── admin.js            # Dashboard controllers, approval actions, and profile settings
```
