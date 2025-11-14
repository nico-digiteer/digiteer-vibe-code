---
# 🚀 Digiteer Vibe Coder - CrewAI Setup

This guide explains how to set up and run **CrewAI** in your project, both on **Windows** and **Mac**.
---

## Prerequisites

- Python 3.10+ installed
- `pip` installed
- Access to the project repository

---

## 1. Install Uv

`Uv` is required to manage virtual environments and sync your project.

```bash
pip install uv
```

---

## 2. Sync Uv

Ensure `uv` is linked to the project:

```bash
uv sync
```

This command syncs the virtual environment and project dependencies.

---

## 3. Activate Virtual Environment

### **Windows (PowerShell / CMD)**

```powershell
# Activate virtual environment
.\.venv\Scripts\activate
```

You should see `(.venv)` in your terminal, indicating the environment is active.

### **Mac / Linux (Terminal)**

```bash
# Activate virtual environment
source .venv/bin/activate
```

---

## 4. Navigate to Engineering Team Folder

```bash
cd engineering_team
```

Make sure you are inside the correct folder where your CrewAI code lives.

---

## 5. Run CrewAI

```bash
crewai run
```

If everything is set up correctly, you should see:

```
Running the Crew: see `output` folder for the result
```

⚠️ **Common Issues:**

- `program not found`: Make sure `.venv` is activated and `uv` is installed.
- Environment mismatch warning: Ensure the virtual environment path matches `.venv`.

---

## ✅ Notes

- Always activate `.venv` before running `crewai run`.
- For Windows, use PowerShell or CMD consistently.
- For Mac, use the default Terminal or iTerm.

---
