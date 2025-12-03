#!/bin/bash

# Script to create directory structure and fleet.yaml files for selected charts
# directly in the current working directory, with reduced persistence storage for testing.
#
# IMPORTANT:
# 1. Review and update the 'version' field in each fleet.yaml content below
#    to the LATEST STABLE version from the respective chart repository or Artifact Hub.
# 2. Customize the 'values' section in each fleet.yaml to your specific needs.
#    The provided values are minimal examples.
# 3. For production, manage sensitive data like passwords using Kubernetes secrets.

# Base directory will be the current directory where the script is run.
BASE_MANIFEST_DIR="."
echo "Creating application folders and fleet.yaml files in the current directory with reduced storage."

# --- Kube Prometheus Stack ---
APP_NAME_PROM="monitoring-stack"
MANIFEST_PATH_PROM="${BASE_MANIFEST_DIR}/${APP_NAME_PROM}"
mkdir -p "${MANIFEST_PATH_PROM}"
cat <<EOF >"${MANIFEST_PATH_PROM}/fleet.yaml"
defaultNamespace: monitoring

helm:
  repo: https://prometheus-community.github.io/helm-charts
  chart: kube-prometheus-stack
  version: "58.0.0" # Verify latest
  releaseName: prometheus-stack-main
  values:
    alertmanager:
      enabled: true
      config:
        global:
          resolve_timeout: 5m
        route:
          group_by: ['job']
          group_wait: 30s
          group_interval: 5m
          repeat_interval: 12h
          receiver: 'null'
        receivers:
        - name: 'null'
    grafana:
      enabled: true
      persistence:
        enabled: true
        type: pvc
        storageClassName: "standard"
        accessModes:
          - ReadWriteOnce
        size: "512Mi"
    prometheus:
      enabled: true
      # prometheusSpec:
      #   storageSpec:
      #     volumeClaimTemplate:
      #       spec:
      #         storageClassName: "standard"
      #         accessModes: ["ReadWriteOnce"]
      #         resources:
      #           requests:
      #             storage: "512Mi"
  waitForJobs: true
  timeoutSeconds: 900
EOF
echo "Created ${MANIFEST_PATH_PROM}/fleet.yaml"

# --- WordPress (Bitnami) ---
APP_NAME_WP="wordpress"
MANIFEST_PATH_WP="${BASE_MANIFEST_DIR}/${APP_NAME_WP}"
mkdir -p "${MANIFEST_PATH_WP}"
cat <<EOF >"${MANIFEST_PATH_WP}/fleet.yaml"
defaultNamespace: wordpress

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: wordpress
  version: "19.2.2" # Verify latest
  releaseName: wordpress-main
  values:
    wordpressUsername: admin
    wordpressEmail: user@example.com
    wordpressBlogName: "My Fleet Managed Blog"
    mariadb:
      enabled: true
      primary:
        persistence:
          enabled: true
          size: "512Mi"
    persistence:
      enabled: true
      size: "512Mi"
  waitForJobs: true
  timeoutSeconds: 600
EOF
echo "Created ${MANIFEST_PATH_WP}/fleet.yaml"

# --- PostgreSQL HA (Bitnami - Pgpool-II) ---
APP_NAME_PGHA="postgresql-ha"
MANIFEST_PATH_PGHA="${BASE_MANIFEST_DIR}/${APP_NAME_PGHA}"
mkdir -p "${MANIFEST_PATH_PGHA}"
cat <<EOF >"${MANIFEST_PATH_PGHA}/fleet.yaml"
defaultNamespace: postgresql-ha

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: postgresql-ha
  version: "13.1.3" # Verify latest
  releaseName: pg-ha-main
  values:
    postgresql:
      persistence:
        enabled: true
        size: "512Mi"
    pgpool:
      replicaCount: 2
      persistence:
        enabled: true
        size: "256Mi"
  waitForJobs: true
  timeoutSeconds: 900
EOF
echo "Created ${MANIFEST_PATH_PGHA}/fleet.yaml"

# --- RabbitMQ (Bitnami) ---
APP_NAME_RMQ="rabbitmq"
MANIFEST_PATH_RMQ="${BASE_MANIFEST_DIR}/${APP_NAME_RMQ}"
mkdir -p "${MANIFEST_PATH_RMQ}"
cat <<EOF >"${MANIFEST_PATH_RMQ}/fleet.yaml"
defaultNamespace: rabbitmq

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: rabbitmq
  version: "14.2.0" # Verify latest
  releaseName: rabbitmq-main
  values:
    replicaCount: 3
    persistence:
      enabled: true
      storageClassName: "standard"
      size: "512Mi"
  waitForJobs: true
  timeoutSeconds: 700
EOF
echo "Created ${MANIFEST_PATH_RMQ}/fleet.yaml"

# --- Keycloak (Bitnami) ---
APP_NAME_KC="keycloak"
MANIFEST_PATH_KC="${BASE_MANIFEST_DIR}/${APP_NAME_KC}"
mkdir -p "${MANIFEST_PATH_KC}"
cat <<EOF >"${MANIFEST_PATH_KC}/fleet.yaml"
defaultNamespace: keycloak

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: keycloak
  version: "19.3.3" # Verify latest
  releaseName: keycloak-main
  values:
    postgresql:
      enabled: true
      primary:
        persistence:
          enabled: true
          size: "512Mi"
  waitForJobs: true
  timeoutSeconds: 800
EOF
echo "Created ${MANIFEST_PATH_KC}/fleet.yaml"

# --- Kafka (Bitnami) ---
APP_NAME_KAFKA="kafka"
MANIFEST_PATH_KAFKA="${BASE_MANIFEST_DIR}/${APP_NAME_KAFKA}"
mkdir -p "${MANIFEST_PATH_KAFKA}"
cat <<EOF >"${MANIFEST_PATH_KAFKA}/fleet.yaml"
defaultNamespace: kafka

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: kafka
  version: "28.1.1" # Verify latest
  releaseName: kafka-main
  values:
    replicaCount: 3
    persistence:
      enabled: true
      size: "512Mi"
    # zookeeper:
    #   persistence:
    #     size: "256Mi"
  waitForJobs: true
  timeoutSeconds: 1000
EOF
echo "Created ${MANIFEST_PATH_KAFKA}/fleet.yaml"

# --- Redis (Bitnami) ---
APP_NAME_REDIS="redis"
MANIFEST_PATH_REDIS="${BASE_MANIFEST_DIR}/${APP_NAME_REDIS}"
mkdir -p "${MANIFEST_PATH_REDIS}"
cat <<EOF >"${MANIFEST_PATH_REDIS}/fleet.yaml"
defaultNamespace: redis

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: redis
  version: "18.10.1" # Verify latest
  releaseName: redis-main
  values:
    # For a standalone Redis with persistence:
    master:
      persistence:
        enabled: true
        size: "256Mi"
    # For a Redis cluster, you'd configure 'cluster.enabled=true'
    # and adjust replica counts and persistence for master/slave groups.
    # cluster:
    #   enabled: false
    # replica:
    #   replicaCount: 1 # For standalone, or adjust for cluster
  waitForJobs: true
  timeoutSeconds: 600
EOF
echo "Created ${MANIFEST_PATH_REDIS}/fleet.yaml"

# --- MongoDB (Bitnami) ---
APP_NAME_MONGO="mongodb"
MANIFEST_PATH_MONGO="${BASE_MANIFEST_DIR}/${APP_NAME_MONGO}"
mkdir -p "${MANIFEST_PATH_MONGO}"
cat <<EOF >"${MANIFEST_PATH_MONGO}/fleet.yaml"
defaultNamespace: mongodb

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: mongodb
  version: "15.7.0" # Verify latest
  releaseName: mongodb-main
  values:
    # architecture: "replicaset" # or "standalone"
    # auth:
    #   rootUser: "admin"
    #   rootPassword: "yourmongopassword"
    persistence:
      enabled: true
      size: "512Mi"
  waitForJobs: true
  timeoutSeconds: 800
EOF
echo "Created ${MANIFEST_PATH_MONGO}/fleet.yaml"

# --- Jenkins (Bitnami) ---
APP_NAME_JENKINS="jenkins"
MANIFEST_PATH_JENKINS="${BASE_MANIFEST_DIR}/${APP_NAME_JENKINS}"
mkdir -p "${MANIFEST_PATH_JENKINS}"
cat <<EOF >"${MANIFEST_PATH_JENKINS}/fleet.yaml"
defaultNamespace: jenkins

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: jenkins
  version: "12.4.1" # Verify latest
  releaseName: jenkins-main
  values:
    # controller:
    #   admin:
    #     user: "admin"
    #     password: "yourjenkinspassword"
    controller: # Renamed from 'master' in newer chart versions
      persistence:
        enabled: true
        size: "512Mi"
    # agent: # Formerly 'agent'
    #   enabled: false # Disable default Kubernetes agent if not needed for simple setup
  waitForJobs: true
  timeoutSeconds: 700
EOF
echo "Created ${MANIFEST_PATH_JENKINS}/fleet.yaml"

# --- SonarQube (Bitnami) ---
APP_NAME_SONAR="sonarqube"
MANIFEST_PATH_SONAR="${BASE_MANIFEST_DIR}/${APP_NAME_SONAR}"
mkdir -p "${MANIFEST_PATH_SONAR}"
cat <<EOF >"${MANIFEST_PATH_SONAR}/fleet.yaml"
defaultNamespace: sonarqube

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: sonarqube
  version: "11.1.0" # Verify latest
  releaseName: sonarqube-main
  values:
    # sonarqubePassword: "yoursonarpassword"
    persistence:
      enabled: true
      size: "512Mi"
    # For production, use an external PostgreSQL or the bundled one:
    postgresql:
      enabled: true
      persistence:
        size: "512Mi"
  waitForJobs: true
  timeoutSeconds: 800
EOF
echo "Created ${MANIFEST_PATH_SONAR}/fleet.yaml"

# --- MinIO (Bitnami) ---
APP_NAME_MINIO="minio"
MANIFEST_PATH_MINIO="${BASE_MANIFEST_DIR}/${APP_NAME_MINIO}"
mkdir -p "${MANIFEST_PATH_MINIO}"
cat <<EOF >"${MANIFEST_PATH_MINIO}/fleet.yaml"
defaultNamespace: minio

helm:
  repo: https://charts.bitnami.com/bitnami
  chart: minio
  version: "14.6.6" # Verify latest
  releaseName: minio-main
  values:
    # auth:
    #   rootUser: "minioadmin"
    #   rootPassword: "miniostoragepassword"
    mode: standalone # or "distributed"
    persistence:
      enabled: true
      size: "512Mi" # For standalone. Distributed mode has different persistence needs.
    # For distributed mode, you would specify replicaCount (must be 4 to 16)
    # replicaCount: 4
  waitForJobs: true
  timeoutSeconds: 600
EOF
echo "Created ${MANIFEST_PATH_MINIO}/fleet.yaml"

echo ""
echo "All application folders and fleet.yaml files created in the current directory with reduced storage and more apps."
echo "Remember to review and customize chart versions and values as needed!"
