# Status Page Infrastructure & GitOps

Complete production-ready infrastructure, GitOps deployment, High Availability, and Observability stack for the Status Page application on K3s (AWS EC2).

---

## 🏗 Architecture Overview

* **Application Layer:** Django Status-Page web servers, Redis-backed RQ Worker, and Scheduled cron tasks.
* **Database & Persistence:** PostgreSQL with persistent storage provisioned via K3s local-path-provisioner.
* **Traffic Routing:** Ingress Controller managing incoming traffic over port 80/443 directly to internal services.
* **Continuous Delivery (GitOps):** ArgoCD synchronizing application states directly from this repository with self-healing enabled.
* **High Availability (HA):** Pod Disruption Budgets (status-page-web-pdb) ensuring zero downtime during updates or node drains (minAvailable: 1).
* **Observability & Alerting:** kube-prometheus-stack scraping cluster metrics with Grafana dashboards and Alertmanager configured with Gmail SMTP routing for critical pod crashes and service downtime.

---

## 📁 Repository Structure

status-page-gitops/
├── apps/
│   └── status-page/            # Core deployment manifests (Web, RQ, Scheduler, DBs, Ingress)
├── argocd/                     # ArgoCD Application definitions for GitOps sync
├── ha/                         # PodDisruptionBudget (PDB) configurations
└── monitoring/                 # Alertmanager notification templates and rules

---

## 🚀 Resilience & Verification

1. **Self-Healing & HA:** Tested pod deletion under load; traffic smoothly routes to active replica without user-facing disruption.
2. **Data Persistence:** Database pods safely recover after intentional deletions retaining all incident history from persistent volumes.
3. **Alert Routing:** Verified end-to-end alert delivery via Gmail SMTP during simulated failure events.
