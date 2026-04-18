# SafeBite - Food Ingredient Analyzer

## 1. Project Overview
SafeBite is a mobile application designed to help users understand food labels instantly. By using the smartphone camera, the app scans ingredient lists, identifies harmful additives (E-numbers), and alerts users about potential allergens or health risks based on their personal profiles.

### Target Users:
- People with food allergies (Peanut, Lactose, Gluten, etc.).
- Individuals with chronic diseases (Diabetes, Hypertension).
- Health-conscious consumers and parents.

---

## 2. Key Features
- **Smart Ingredient Scanner:** Real-time OCR to extract text from food packaging.
- **AI Analysis:** Classifies ingredients into Safe, Caution, or Harmful.
- **Personal Health Profile:** Customized alerts for specific allergies or diets.
- **Safety History:** Save and review previously scanned products.

---

## 3. Technology Stack
- **Frontend:** Flutter (Dart)
- **OCR Engine:** Google ML Kit (On-device)
- **AI Analysis:** TensorFlow Lite
- **Backend & DB:** Firebase (Authentication & Firestore)
- **Design:** Figma

---

## 4. Team Members & Roles
| Name | Role | Primary Tasks |
| :--- | :--- | :--- |
| **Duy** | Frontend | Flutter Architecture, Camera & ML Kit Integration |
| **Huy** | Project Manager & AI Specialist | Data Collection, AI Training |
| **Hoang** | Backend Developer | Firebase Setup, API Integration, User Data Management |
| **Dat** | UI/UX & QA | Design Wireframes, Testing, Documentation |

---

## 5. Work Breakdown Structure (WBS) - Semester Timeline

### Week 1: Initialization 
- Project proposal & Team alignment.
- Tech stack selection & GitHub setup.
- Initial UI/UX Wireframes.

### Week 2 - 3: Core Development
- Flutter Camera & OCR (Google ML Kit) implementation.
- Ingredient Database collection (E-numbers, Allergens).
- Firebase Authentication setup.

### Week 4: AI Integration
- Connect OCR text with AI analysis engine.
- Build Personal Profile and Health Alert logic.

### Week 5: Finalization
- UI/UX Refinement & Animations.
- Testing (Unit test & User Acceptance Test).
- Final Presentation.

---

## 6. Repository Structure
- `/mobile_app`: Flutter source code.
- `/ai_backend`: AI logic and data processing scripts.
- `/docs`: Meeting minutes, UI designs, and project reports.

---

## 7. Communication Plan
- **Primary Tools:** Google Meet (Weekly Meetings), Messenger (Daily Chat).
- **Task Management:** GitHub Projects (Kanban Board).
- **Meeting Frequency:** Twice a week (Tuesday & Saturday).
