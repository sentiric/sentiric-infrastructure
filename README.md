# 🚀 Sentiric Infrastructure: Platform Orchestration Hub

This repository is the central orchestration hub for the entire Sentiric platform. It uses Docker Compose, including profiles and includes, to manage all microservices for both **local development** and **multi-server production** environments.

---

## 1. Local Development Setup (Single Machine)

This setup is ideal for developers to run the entire platform on their local machine.

### Prerequisites
- Docker and Docker Compose
- Git
- All Sentiric service repositories cloned into the same parent directory.

### Instructions
1.  **Clone all necessary repositories:**
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
    Open `.env` and adjust `PUBLIC_IP` if needed.

3.  **Run the platform:**
    ```bash
    docker compose up --build -d
    ```

4.  **Run specific services:**
    To work on a specific service, you can start it along with its core dependencies:
    ```bash
    docker compose up --build -d agent-service rabbitmq
    ```

5.  **Stop the platform:**
    ```bash
    docker compose down --volumes
    ```

---

## 2. Production Deployment (Multi-Server Example)

This setup demonstrates how to deploy the platform across multiple servers (e.g., a Telekom Gateway, an Application Server, and a Data Server) using Docker Compose Profiles.

### Prerequisites
- Each server must have Docker and Docker Compose installed.
- You must have a `.env.prod` file on each server containing the necessary environment variables. Use `.env.prod.example` as a template.

### Instructions

1.  **On the Telekom Gateway Server (e.g., Public Static IP):**
    This server runs services that need direct public access for real-time communication.
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-telekom.yml up -d
    ```

2.  **On the Application & AI Server:**
    This server runs the core business logic and AI services.
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-app.yml up -d
    ```

3.  **On the Data Server:**
    This server runs the stateful services like databases and message brokers.
    ```bash
    docker compose -f docker-compose.yml -f compose/profiles/prod-data.yml up -d
    ```