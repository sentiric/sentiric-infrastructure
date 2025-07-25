# 🚀 Sentiric Infrastructure: Platform Orchestration Hub

This repository is the **single source of truth** for orchestrating the entire Sentiric platform. It uses a unified Docker Compose file with profiles to manage all microservices for both **local development** and **multi-server production** environments.

---

## 1. Local Development Setup (Recommended)

This setup runs all necessary services on your local machine, tagged with the `default` profile.

### Prerequisites
- Docker and Docker Compose
- Git
- All Sentiric service repositories cloned into the same parent directory as this one.

### Instructions
1.  **Clone all repositories:**
    Your workspace directory should look like this:
    ```
    /workspace/
    ├── sentiric-infrastructure/  <-- You are here
    ├── sentiric-agent-service/
    └── ... and all other services
    ```

2.  **Configure your local environment:**
    ```bash
    cp .env.local.example .env
    ```
    Open `.env` and adjust `PUBLIC_IP` if needed for your local network setup.

3.  **Run the entire platform:**
    This command will build all services and start the ones marked with the `default` profile.
    ```bash
    docker compose up --build -d
    ```

4.  **Check the status:**
    ```bash
    docker compose ps
    ```

5.  **Stop the platform:**
    ```bash
    docker compose down --volumes
    ```

---

## 2. Production Deployment (Multi-Server Example)

This setup demonstrates how to deploy the platform across multiple servers using Docker Compose Profiles. You only need to clone this `infrastructure` repo and the relevant service repos on each server.

### Prerequisites
- Each server must have Docker and Docker Compose installed.
- Create a `.env` file on each server using `.env.prod.example` as a template, filling in the correct IP addresses for inter-server communication.

### Instructions

1.  **On the Data Server:**
    ```bash
    docker compose --profile data up --build -d
    ```

2.  **On the Telekom Gateway Server:**
    ```bash
    docker compose --profile telekom up --build -d
    ```

3.  **On the Application & AI Server:**
    ```bash
    docker compose --profile app up --build -d
    ```