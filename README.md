# DARK-COM-2 :: High-Performance cURL-Compatible Headless Browser Engine

**Dark-Com-2** is a lightweight, high-performance command-line HTTP client and headless browser engine built on native Win32 API and pure C. Powered by the Microsoft Edge WebView2 Evergreen Runtime, it bridges standard cURL CLI semantics with a full Chromium execution core, enabling automated telemetry, scriptable API testing, and persistent session management across local networks and remote hosts.

---

## 🚀 Key Features

* **Full cURL CLI Parity:** Supports standard command-line argument ordering (URL first, flags first, and long-flag formats) for seamless integration into existing shell scripts and automation workflows.
* **Persistent Session Management:** Automatically maintains cookie stores, local storage, and server session tokens (such as `PHPSESSID`) across sequential invocations via a local state profile directory.
* **Local & Remote Network Support:** Engineered to communicate effortlessly with local loopback (`localhost`, `127.0.0.1`), local network subnets, and remote production servers.
* **Asynchronous IPC Architecture:** Decoupled host executable and core DLL layout utilizing high-speed native message routing to bypass thread locks and promise serialization overhead.

---

## 📦 Redistributable Package Layout

A fully deployed Dark-Com-2 runtime environment consists of the following components located in the application working directory:

| Filename | Component Type | Description |
| --- | --- | --- |
| `darkcom2.exe` | CLI Host Executable | Parses command-line arguments, manages the Win32 message loop, and handles console I/O. |
| `DarkComHeadless.dll` | Core Engine Library | Manages WebView2 execution, document origin bindings, and asynchronous fetch routing. |
| `darkcom_browser_profile/` | Persistent Data Store | Automatically provisioned directory maintaining session cookies, cache, and browser state. |

*Note: The target host operating system must have the **Microsoft Edge WebView2 Evergreen Runtime** installed.*

---

## 💻 Command-Line Reference & Usage

```cmd
darkcom2.exe [options] <url>

```

### Supported Flags

* `-X, --request <method>` — Specifies the HTTP request method (`GET`, `POST`, `PUT`, `DELETE`). Supplying data automatically promotes `GET` requests to `POST`.
* `-d, --data <data>` — Supplies a payload string or raw JSON body for transmission.
* `-H, --header <header>` — Passes custom HTTP headers (e.g., `-H "Content-Type: application/json"`).
* `-v, --verbose` — Enables detailed wire tracing, outputting simulated cURL request frames (`>`) and response headers (`<`).

### Examples

**Standard cURL Style (URL First):**

```cmd
darkcom2.exe http://localhost:8080/echo.php -X POST -d "{\"action\":\"test_url_first\"}" -v

```

**Alternative Flag-First Style:**

```cmd
darkcom2.exe -X POST -d "{\"action\":\"test_flags_first\"}" http://localhost:8080/echo.php --verbose

```

**Long Flags Style:**

```cmd
darkcom2.exe --request POST --data "{\"action\":\"test_long_flags\"}" http://localhost:8080/echo.php -v

```

---

## 🛠️ System Requirements & Deployment

* **Operating System:** Windows 10 or Windows 11 (64-bit x64 architecture).
* **Runtime Dependency:** Microsoft Edge WebView2 Evergreen Runtime.
* **Permissions:** Read/write access in the execution directory for automated profile persistence and session caching.
---

# PART I: DARK-COM-2 END-USER CLI MANUAL

## 1. Overview & Syntax

`darkcom2.exe` is a high-performance, cURL-compatible command-line HTTP client powered by an embedded Microsoft Edge WebView2 execution core. It supports standard command-line ordering, persistent session/cookie management, and custom payload injection.

```cmd
darkcom2.exe [options] <url>

```

## 2. Command-Line Flags Reference

| Short Flag | Long Flag | Description |
| --- | --- | --- |
| `-X` | `--request <method>` | Specifies the HTTP method to use (e.g., `GET`, `POST`, `PUT`, `DELETE`). Defaults to `GET` unless a payload is supplied. |
| `-d` | `--data <data>` | Supplies a raw string or JSON payload body for transmission. Providing data automatically promotes the request method to `POST`. |
| `-H` | `--header <header>` | Passes custom HTTP headers (e.g., `-H "Content-Type: application/json"`). |
| `-v` | `--verbose` | Enables detailed wire logging, mirroring standard cURL output formatting (`>` for outbound requests, `<` for inbound response headers). |

## 3. Usage Examples

**Standard cURL Style (URL First):**

```cmd
darkcom2.exe http://localhost:8080/echo.php -X POST -d "{\"action\":\"test\"}" -v

```

**Alternative Flag-First Style:**

```cmd
darkcom2.exe -X POST -d "{\"action\":\"test\"}" http://localhost:8080/echo.php --verbose

```

**Long Flags Style:**

```cmd
darkcom2.exe --request POST --data "{\"action\":\"test\"}" http://localhost:8080/echo.php -v

```

## 4. State Persistence & Local Profile

* **Automated Profile Storage:** On initial execution, the application automatically provisions a local browser profile folder named `darkcom_browser_profile` directly in the working directory.
* **Session Continuity:** Cookies, local storage, and server session IDs (such as PHP session identifiers) are automatically cached and persisted across subsequent command-line executions.

---

# PART II: REDISTRIBUTABLE SDK & DEPLOYMENT REFERENCE

## 1. Redistributable Package Layout

Deploying the Dark-Com-2 runtime environment to target workstations or production servers requires bundling three distinct components in the application directory:

1. **`darkcom2.exe`** — The primary command-line host executable.
2. **`DarkComHeadless.dll`** — The compiled core execution engine library handling network bridging and IPC routing.
3. **Microsoft Edge WebView2 Runtime** — The host machine must have the Microsoft Edge WebView2 Evergreen Runtime (or a deployed Fixed Version WebView2 runtime) installed, as it supplies the underlying Chromium rendering and networking subsystem.

## 2. Environment & Runtime Requirements

* **Operating System:** Windows 10 or Windows 11 (64-bit x64 architecture).
* **Network Permissions:** Outbound TCP access on target ports (e.g., HTTP/HTTPS traffic on standard ports or local loopback `127.0.0.1` / `localhost` ports).
* **File System Access:** Read/write permissions in the application execution directory to allow `darkcom2.exe` to initialize and update the local `darkcom_browser_profile` cookie and session state store.


## Installation

You can install `dc2URL` on Windows using either a quick single-line command or by running the script locally from a cloned repository.

### Method 1: Quick Install (PowerShell IRM)
The fastest way to install is to copy and paste the single-line command below into an open **Command Prompt** or **PowerShell** window. This downloads and executes the deployment script directly in memory:

```cmd
powershell -Command "irm https://githubusercontent.com | iex"
```

---

### Method 2: Local Install (Git Clone)
If you prefer to clone the repository or manage the files manually:

1. Clone the repository to your machine:
   ```bash
   git clone https://github.com
   ```
2. Navigate into the version directory:
   ```bash
   cd dc2URL/v1.0
   ```
3. Open or run the local batch installer:
   * **Double-click** the `install.bat` file inside the directory.
   * *Or*, copy and paste the batch script content directly into your command line interface from this directory context.

#### Local Installer Script Source Code
*(Paste your modified batch code block right below this line)*


mercwar/dc2URL/
└── v1.0/
    ├── install.bat      <-- Unified Master Handoff Wrapper
    ├── menu.bat         <-- Interactive UI Selector Path
    ├── git.bat          <-- Native Git Downloader and Verification Core
    ├── copy.bat         <-- Isolated File Snychronizer
    ├── reg.bat          <-- Custom Protocol and PATH Environment Mapper
    ├── echo.bat         <-- Diagnostics
    ├── favi-con.ico
    └── exec/            <-- Binary Payload Cache Folder
        ├── darkcom2.exe
        ├── DarkComHeadless.dll
        └── WebView2Loader.dll
mercwar/dc2URL/
└── v1.0/
    ├── install.bat      <-- Master Orchestrator (Root level)
    ├── uninstall.bat    <-- Master Uninstaller (Root level)
    ├── install.ps1      <-- Web IRM Script (Root level)
    ├── echo.bat         <-- Validation Utility
    ├── favi-con.ico     <-- Root Icon Asset
    ├── readme.MD        <-- Documentation Frame
    ├── exec/            <-- Executable Binaries Subfolder
    │   ├── darkcom2.exe
    │   ├── DarkComHeadless.dll
    │   └── WebView2Loader.dll
    ├── images/          <-- Documentation Graphics Subfolder
    │   └── cmd-src.png
    └── shell/           <-- Helper Modular Batch Subfolder
        ├── menu.bat
        ├── git.bat
        ├── copy.bat
        └── reg.bat
