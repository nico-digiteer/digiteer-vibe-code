
---

# 🚀 Digiteer Vibe Coder - CrewAI Setup

This guide explains how to set up and run **CrewAI** in your project, for **Windows**, **Mac**, and **WSL**.

---

## Prerequisites

* Python 3.10+ installed
* `pip` installed
* Access to the project repository
* For WSL: WSL2 installed and Linux distro set up

---

## 1. Install Uv (Optional)

`Uv` is only required if you want to manage virtual environments and sync your project automatically.

```bash
pip install uv
```

Or via shell script:

```bash
wget -qO- https://astral.sh/uv/install.sh | sh
```

> If `uv` is already installed, you can skip this step.

---

## 2. Sync Uv

If using `uv`, sync it with the project:

```bash
uv sync
```

---

## 3. Create `.env` File

Create a `.env` file **inside the `src/` directory** with your project credentials. Example:

```
# src/.env
OPENAI_API_KEY=sk-proj...
```

> Replace the placeholder with your actual key(s).

---

## 4. Activate Virtual Environment

### **Windows (PowerShell / CMD)**

```powershell
.\.venv\Scripts\activate
```

### **Mac / Linux / WSL (Terminal)**

```bash
source .venv/bin/activate
```

> You should see `(.your_venv_name)` in your terminal.

> **WSL Tip:** Make sure your project folder is inside your Linux filesystem (`/home/<user>/...`) and not mounted Windows drive (`/mnt/c/...`) to avoid path issues.

---

## 5. Navigate to Engineering Team Folder

```bash
cd engineering_team
```

---

## 6. Run CrewAI

```bash
crewai run
```

Expected output:

```
Running the Crew: see `output` folder for the result
```

⚠️ **Common Issues:**

* `program not found`: Ensure `.venv` is activated.
* Environment mismatch warning: Ensure the virtual environment path matches `.venv`.
* WSL users: Make sure the `uv` binary is installed in WSL, not Windows.

---

## ✅ Notes

* Always activate `.venv` before running `crewai run`.
* Keep `.env` inside `src/`.
* For Windows, use PowerShell or CMD consistently.
* For Mac / Linux / WSL, use the default terminal.
* On WSL, avoid running `.venv` from mounted Windows drives to prevent permission/path errors.

---

