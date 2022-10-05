# mailu

![Version: 0.3.3](https://img.shields.io/badge/Version-0.3.3-informational?style=flat-square) ![AppVersion: 1.9](https://img.shields.io/badge/AppVersion-1.9-informational?style=flat-square)

This chart installs the Mailu mail system on kubernetes

**Homepage:** <https://mailu.io>

## Compatibility

| Chart Version       | Mailu Version |
| ------------------- | ------------- |
| 0.0.x, 0.1.x, 0.2.x | 1.8           |
| 0.3.x               | 1.9.x         |

Active development of this chart is only for the latest supported Mailu version (currently 1.9.x).
Branches exists for older mailu versions (e.g. old/mailu-1.8).

## Prerequisites

- ⚠️Starting with version 1.9, you need a validating DNSSEC compatible resolver in order to run Mailu.
- a working HTTP/HTTPS ingress controller such as nginx or traefik
- cert-manager v0.12 or higher installed and configured (including a working cert issuer). Otherwise you will need to handle it by yourself and provide the secret to Mailu.
- A node which has a public reachable IP, static address because mail service binds directly to the node's IP
- A hosting service that allows inbound and outbound traffic on port 25.
- Helm 3 (helm 2 support is dropped with release 0.3.0).

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 2.0.3 |
| https://charts.bitnami.com/bitnami | mariadb | 11.3.* |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.* |

### Warning about open relays

One of the biggest mistakes when running a mail server is a so called "Open Relay". This kind of misconfiguration is in most cases caused by a badly configured
load balancer which hides the originating IP address of an email which makes Mailu think, the email comes from an internal address and ommits authentification and other checks. In the result, your mail server can be abused to spread spam and will get blacklisted within hours.

It is very important that you check your setup for open relay at least:

- after installation
- at any time you change network settings or load balancer configuration

The check is quite simple:

- watch the logs for the "mailu-front" POD
- browse to an open relay checker like <https://mxtoolbox.com/diagnostic.aspx>
- enter the hostname or IP address of your mail server and start the test

In the logs, you should see some message like

```bash
2021/10/26 21:23:25 [info] 12#12: *25691 client 18.205.72.90:56741 connected to 0.0.0.0:25
```

It is very important that the IP address shown here is an external public IP address, not an internal like 10.x.x.x, 192.168.x.x or 172.x.x.x.

Also verify that the result of the check confirms that there is no open relay:

```bash
SMTP Open Relay OK - Not an open relay.
```

### Warning, this will not work on most cloud providers

- Google cloud does not allow outgoing connections to connect to port 25. You will not be able to send
  mails with mailu on google cloud (<https://googlecloudplatform.uservoice.com/forums/302595-compute-engine/suggestions/12422808-please-unblock-port-25-allow-outbound-mail-connec>)
- Many cloud providers don't allow to assign fixed IPs directly to nodes. They use proxies or load balancers instead. While
  this works well with HTTP/HTTPs, on raw TCP connections (such as mail protocol connections) the originating IP get's lost.
  There's a so called "proxy protocol" as a solution for this limitation but that's not yet supported by mailu (due the lack of
  support in the nginx mail modules). Without the original IP information, a mail server will not work properly, or worse, will be
  an open relay.
- If you'd like to run mailu on kubernetes, consider to rent a cheap VPS and run kuberneres on it (e.g. using rancher2). A good option is to
  use hetzner cloud VPS (author's personal opinion).
- Please don't open issues in the bug tracker if your mail server is not working because your cloud provider blocks port 25 or hides
  source ip addresses behind a load balancer.

## Installation

- Add the repository via:

```bash
helm repo add mailu https://mailu.github.io/helm-charts/
```

- create a local values file:

```bash
helm show values mailu/mailu > my-values-file.yaml
```

Edit the `my-values-file.yaml` to reflect your environment.

- deploy the helm-chart with:

```bash
helm install mailu mailu/mailu -n mailu-mailserver --values my-values-file.yaml
```

- Uninstall the helm-chart with:

```bash
helm uninstall mailu --namespace=mailu-mailserver
```

Check that the deployed pods are all running.

## Parameters

### Global parameters

| Name                      | Description                                       | Value |
| ------------------------- | ------------------------------------------------- | ----- |
| `global.imageRegistry`    | Global container image registry                   | `""`  |
| `global.imagePullSecrets` | Global container image pull secret                | `[]`  |
| `global.storageClass`     | Global storageClass to use for persistent volumes | `""`  |

### Common parameters

| Name                | Description                                                                          | Value |
| ------------------- | ------------------------------------------------------------------------------------ | ----- |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                 | `""`  |
| `nameOverride`      | String to partially override mailu.fullname include (will maintain the release name) | `""`  |
| `fullnameOverride`  | String to fully override mailu.fullname template                                     | `""`  |
| `commonLabels`      | Add labels to all the deployed resources                                             | `{}`  |
| `commonAnnotations` | Add annotations to all the deployed resources                                        | `{}`  |

### Mailu parameters

| Name                                 | Description                                                                                                                       | Value           |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `hostnames`                          | List of hostnames to generate certificates and ingresses for. The first will be used as primary mail hostname                     | `[]`            |
| `domain`                             | Mail domain name. See https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames | `""`            |
| `secretKey`                          | The secret key is required for protecting authentication cookies and must be set individually for each deployment                 | `""`            |
| `existingSecret`                     | Name of the existing secret to retrieve the secretKey.                                                                            | `""`            |
| `initialAccount`                     | An initial account can automatically be created:                                                                                  | `{}`            |
| `subnet`                             | Change this if you're using different address ranges for pods                                                                     | `10.42.0.0/16`  |
| `mailuVersion`                       | Version/tag of mailu images - must be master or a version >= 1.9                                                                  | `1.9.26`        |
| `logLevel`                           | default log level. can be overridden globally or per service                                                                      | `WARNING`       |
| `postmaster`                         | local part of the postmaster email address (Mailu will use @$DOMAIN as domain part)                                               | `postmaster`    |
| `mail.messageSizeLimitInMegabytes`   | Maximum size of an email in megabytes                                                                                             | `50`            |
| `mail.authRatelimit.ip`              | Sets the `AUTH_RATELIMIT_IP` environment variable in the `admin` pod                                                              | `60/hour`       |
| `mail.authRatelimit.ipv4Mask`        | Sets the `AUTH_RATELIMIT_IP_V4_MASK` environment variable in the `admin` pod                                                      | `24`            |
| `mail.authRatelimit.ipv6Mask`        | Sets the `AUTH_RATELIMIT_IP_V6_MASK` environment variable in the `admin` pod                                                      | `56`            |
| `mail.authRatelimit.user`            | Sets the `AUTH_RATELIMIT_USER` environment variable in the `admin` pod                                                            | `100/day`       |
| `mail.authRatelimit.exemptionLength` | Sets the `AUTH_RATELIMIT_EXEMPTION_LENGTH` environment variable in the `admin` pod                                                | `86400`         |
| `mail.authRatelimit.exemption`       | Sets the `AUTH_RATELIMIT_EXEMPTION` environment variable in the `admin` pod                                                       | `""`            |
| `mail.messageRatelimit.value`        | Sets the `MESSAGE_RATELIMIT` environment variable in the `admin` pod                                                              | `200/day`       |
| `mail.messageRatelimit.exemption`    | Sets the `MESSAGE_RATELIMIT_EXEMPTION` environment variable in the `admin` pod                                                    | `""`            |
| `external_relay`                     | Mailu external relay configuration                                                                                                | `{}`            |
| `clusterDomain`                      | Kubernetes cluster domain name                                                                                                    | `cluster.local` |
| `tolerations`                        | Tolerations for pod assignment                                                                                                    | `[]`            |
| `affinity`                           | Affinity for pod assignment                                                                                                       | `{}`            |

### Storage parameters

| Name                                                | Description                                                                                                                                                                                               | Value                  |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `database.type`                                     | type of the database for mailu (sqlite/mysql/postgresql)                                                                                                                                                  | `sqlite`               |
| `database.roundcube.type`                           | type of the database for roundcube (sqlite/mysql/postgresql)                                                                                                                                              | `sqlite`               |
| `database.roundcube.database`                       | Name of the roundcube database                                                                                                                                                                            | `roundcube`            |
| `database.roundcube.username`                       | Username to use for the roundcube database                                                                                                                                                                | `roundcube`            |
| `database.roundcube.password`                       | Password to use for the roundcube database                                                                                                                                                                | `changeme`             |
| `database.mysql`                                    | For 'mysql' type (or mariadb) use the following config:                                                                                                                                                   | `{}`                   |
| `database.postgresql`                               | For an external PostgreSQL database, use the following config:                                                                                                                                            | `{}`                   |
| `mariadb.enabled`                                   | Enable MariaDB deployment                                                                                                                                                                                 | `false`                |
| `mariadb.architecture`                              | MariaDB architecture. Allowed values: standalone or replication                                                                                                                                           | `standalone`           |
| `mariadb.auth.rootPassword`                         | Password for the `root` user. Ignored if existing secret is provided.                                                                                                                                     | `changeme`             |
| `mariadb.auth.database`                             | Name for a custom database to create                                                                                                                                                                      | `mailu`                |
| `mariadb.auth.username`                             | Name for a custom user to create                                                                                                                                                                          | `mailu`                |
| `mariadb.auth.password`                             | Password for the new user. Ignored if existing secret is provided                                                                                                                                         | `changeme`             |
| `mariadb.auth.existingSecret`                       | Use existing secret for password details (`auth.rootPassword`, `auth.password`, `auth.replicationPassword`                                                                                                | `""`                   |
| `mariadb.primary.persistence.enabled`               | Enable persistence using PVC                                                                                                                                                                              | `false`                |
| `mariadb.primary.persistence.storageClass`          | PVC Storage Class for MariaDB volume                                                                                                                                                                      | `""`                   |
| `mariadb.primary.persistence.accessMode`            | PVC Access Mode for MariaDB volume                                                                                                                                                                        | `ReadWriteOnce`        |
| `mariadb.primary.persistence.size`                  | PVC Storage Request for MariaDB volume                                                                                                                                                                    | `8Gi`                  |
| `postgresql.enabled`                                | Enable PostgreSQL deployment                                                                                                                                                                              | `false`                |
| `postgresql.architecture`                           | PostgreSQL architecture. Allowed values: standalone or replication                                                                                                                                        | `standalone`           |
| `postgresql.auth.enablePostgresUser`                | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user                                                                                                    | `true`                 |
| `postgresql.auth.postgresPassword`                  | Password for the "postgres" admin user. Ignored if `auth.existingSecret` with key `postgres-password` is provided                                                                                         | `changeme`             |
| `postgresql.auth.username`                          | Name for a custom user to create                                                                                                                                                                          | `mailu`                |
| `postgresql.auth.password`                          | Password for the custom user to create. Ignored if `auth.existingSecret` with key `password` is provided                                                                                                  | `changeme`             |
| `postgresql.auth.database`                          | Name for a custom database to create                                                                                                                                                                      | `mailu`                |
| `postgresql.auth.existingSecret`                    | Use existing secret for password details (`auth.postgresPassword`, `auth.password` will be ignored and picked up from this secret). The secret has to contain the keys `postgres-password` and `password` | `""`                   |
| `postgresql.auth.secretKeys.adminPasswordKey`       | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `postgres-password`    |
| `postgresql.auth.secretKeys.userPasswordKey`        | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `password`             |
| `postgresql.auth.secretKeys.replicationPasswordKey` | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `replication-password` |
| `postgresql.primary.persistence.enabled`            | Enable persistence using PVC                                                                                                                                                                              | `false`                |
| `postgresql.primary.persistence.storageClass`       | PVC Storage Class for PostgreSQL volume                                                                                                                                                                   | `""`                   |
| `postgresql.primary.persistence.accessMode`         | PVC Access Mode for PostgreSQL volume                                                                                                                                                                     | `ReadWriteOnce`        |
| `postgresql.primary.persistence.size`               | PVC Storage Request for PostgreSQL volume                                                                                                                                                                 | `8Gi`                  |
| `persistence.single_pvc`                            | Setings for a single volume for all apps.                                                                                                                                                                 | `true`                 |
| `persistence.size`                                  | Size of the persistent volume claim (for single PVC)                                                                                                                                                      | `100Gi`                |
| `persistence.storageClass`                          | Storage class of backing PVC (for single PVC)                                                                                                                                                             | `""`                   |
| `persistence.accessMode`                            | Access mode of backing PVC (for single PVC)                                                                                                                                                               | `ReadWriteOnce`        |

### Ingress settings

| Name                       | Description                                                                | Value                |
| -------------------------- | -------------------------------------------------------------------------- | -------------------- |
| `certmanager.enabled`      | Enable certmanager (create certificates for all domains)                   | `true`               |
| `certmanager.issuerType`   | Issuer to use for certificates                                             | `ClusterIssuer`      |
| `certmanager.issuerName`   | Name of the issuer to use                                                  | `letsencrypt`        |
| `certmanager.apiVersion`   | Name of the secret to use for certificates                                 | `cert-manager.io/v1` |
| `ingress.externalIngress`  | Enable external ingress                                                    | `true`               |
| `ingress.ingressClassName` | Set the ingress class name for external ingress                            | `""`                 |
| `ingress.annotations`      | Annotations to add to the external ingress                                 | `nil`                |
| `ingress.realIpHeader`     | Sets the value of `REAL_IP_HEADER` environment variable in the `front` pod | `X-Forwarded-For`    |
| `ingress.realIpFrom`       | Sets the value of `REAL_IP_FROM` environment variable in the `front` pod   | `0.0.0.0/0`          |
| `ingress.tlsFlavor`        | Sets the value of `TLS_FLAVOR` environment variable in the `front` pod     | `cert`               |

### Frontend load balancer for non-HTTP(s) services

| Name                                          | Description                                                                           | Value           |
| --------------------------------------------- | ------------------------------------------------------------------------------------- | --------------- |
| `front.logLevel`                              | Override default log level                                                            | `""`            |
| `front.image.repository`                      | Pod image repository                                                                  | `mailu/nginx`   |
| `front.image.tag`                             | Pod image tag (defaults to mailuVersion)                                              | `""`            |
| `front.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`  |
| `front.controller.kind`                       | Deployment or DaemonSet                                                               | `Deployment`    |
| `front.hostPort.enabled`                      | Expose front mail ports via hostPort                                                  | `true`          |
| `front.externalService.enabled`               | Expose front mail ports via external service (ClusterIP or LoadBalancer)              | `false`         |
| `front.externalService.type`                  | Service type (ClusterIP or LoadBalancer)                                              | `ClusterIP`     |
| `front.externalService.externalTrafficPolicy` | Service externalTrafficPolicy (Cluster or Local)                                      | `Local`         |
| `front.externalService.annotations`           | Service annotations                                                                   | `{}`            |
| `front.externalService.pop3`                  | Expose POP3 port                                                                      | `false`         |
| `front.externalService.pop3s`                 | Expose POP3 port (TLS)                                                                | `true`          |
| `front.externalService.imap`                  | Expose IMAP port                                                                      | `false`         |
| `front.externalService.imaps`                 | Expose IMAP port (TLS)                                                                | `true`          |
| `front.externalService.smtp`                  | Expose SMTP port                                                                      | `true`          |
| `front.externalService.smtps`                 | Expose SMTP port (TLS)                                                                | `true`          |
| `front.externalService.submission`            | Expose Submission port                                                                | `true`          |
| `front.resources.limits`                      | The resources limits for the container                                                | `{}`            |
| `front.resources.requests`                    | The requested resources for the container                                             | `{}`            |
| `front.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`          |
| `front.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`             |
| `front.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`            |
| `front.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`            |
| `front.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`             |
| `front.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `5`             |
| `front.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`          |
| `front.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`            |
| `front.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`            |
| `front.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `5`             |
| `front.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `1`             |
| `front.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`             |
| `front.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`         |
| `front.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`            |
| `front.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`            |
| `front.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `5`             |
| `front.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `30`            |
| `front.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`             |
| `front.podLabels`                             | Add extra labels to pod                                                               | `{}`            |
| `front.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`            |
| `front.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`            |
| `front.initContainers`                        | Add additional init containers to the pod                                             | `[]`            |
| `front.priorityClassName`                     | Pods' priorityClassName                                                               | `""`            |
| `front.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`             |
| `front.affinity`                              | Affinity for front pod assignment                                                     | `{}`            |
| `front.tolerations`                           | Tolerations for pod assignment                                                        | `[]`            |
| `front.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`             |
| `front.hostAliases`                           | Pod pod host aliases                                                                  | `[]`            |
| `front.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`            |
| `front.service.annotations`                   | Admin service annotations                                                             | `{}`            |
| `front.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`            |
| `front.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate` |
| `front.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`            |
| `front.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`            |
| `front.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`            |
| `front.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`            |

### Admin parameters

| Name                                       | Description                                                                           | Value               |
| ------------------------------------------ | ------------------------------------------------------------------------------------- | ------------------- |
| `admin.logLevel`                           | Override default log level                                                            | `""`                |
| `admin.image.repository`                   | Pod image repository                                                                  | `mailu/admin`       |
| `admin.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `admin.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `admin.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `admin.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `admin.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `admin.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `admin.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `admin.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `admin.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `admin.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `admin.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `admin.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `admin.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `admin.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `admin.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `admin.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `admin.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `admin.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `admin.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `admin.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `admin.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `admin.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `admin.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `admin.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `admin.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `admin.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `admin.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `admin.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `admin.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `admin.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `admin.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `admin.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `admin.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `admin.affinity`                           | Affinity for admin pod assignment                                                     | `{}`                |
| `admin.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `admin.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `admin.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `admin.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `admin.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `admin.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `admin.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `admin.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `admin.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `admin.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `admin.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### Redis parameters

| Name                                       | Description                                                                           | Value               |
| ------------------------------------------ | ------------------------------------------------------------------------------------- | ------------------- |
| `redis.logLevel`                           | Override default log level                                                            | `""`                |
| `redis.image.repository`                   | Pod image repository                                                                  | `redis`             |
| `redis.image.tag`                          | Pod image tag                                                                         | `5-alpine`          |
| `redis.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `redis.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `redis.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `redis.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `redis.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `redis.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `redis.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `redis.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `redis.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `redis.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `redis.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `redis.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `redis.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `redis.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `redis.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `redis.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `redis.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `redis.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `redis.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `redis.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `redis.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `redis.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `redis.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `redis.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `redis.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `redis.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `redis.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `redis.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `redis.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `redis.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `redis.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `redis.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `redis.affinity`                           | Affinity for redis pod assignment                                                     | `{}`                |
| `redis.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `redis.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `redis.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `redis.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `redis.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `redis.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `redis.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `redis.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `redis.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `redis.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `redis.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### Postfix parameters

| Name                                         | Description                                                                           | Value               |
| -------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `postfix.logLevel`                           | Override default log level                                                            | `""`                |
| `postfix.image.repository`                   | Pod image repository                                                                  | `mailu/postfix`     |
| `postfix.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `postfix.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `postfix.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `postfix.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `postfix.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `postfix.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `postfix.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `postfix.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `postfix.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `postfix.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `postfix.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `postfix.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `postfix.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `postfix.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `postfix.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `postfix.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `postfix.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `postfix.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `postfix.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `postfix.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `postfix.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `postfix.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `postfix.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `postfix.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `postfix.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `postfix.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `postfix.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `postfix.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `postfix.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `postfix.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `postfix.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `postfix.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `postfix.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `postfix.affinity`                           | Affinity for postfix pod assignment                                                   | `{}`                |
| `postfix.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `postfix.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `postfix.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `postfix.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `postfix.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `postfix.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `postfix.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `postfix.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `postfix.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `postfix.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `postfix.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### Dovecot parameters

| Name                                          | Description                                                                           | Value               |
| --------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `dovecot.enabled`                             | Enable dovecot                                                                        | `true`              |
| `dovecot.logLevel`                            | Override default log level                                                            | `""`                |
| `dovecot.image.repository`                    | Pod image repository                                                                  | `mailu/dovecot`     |
| `dovecot.image.tag`                           | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `dovecot.image.pullPolicy`                    | Pod image pull policy                                                                 | `IfNotPresent`      |
| `dovecot.persistence.size`                    | Pod pvc size                                                                          | `20Gi`              |
| `dovecot.persistence.storageClass`            | Pod pvc storage class                                                                 | `""`                |
| `dovecot.persistence.accessModes`             | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `dovecot.persistence.claimNameOverride`       | Pod pvc name override                                                                 | `""`                |
| `dovecot.persistence.annotations`             | Pod pvc annotations                                                                   | `{}`                |
| `dovecot.resources.limits`                    | The resources limits for the container                                                | `{}`                |
| `dovecot.resources.requests`                  | The requested resources for the container                                             | `{}`                |
| `dovecot.livenessProbe.enabled`               | Enable livenessProbe                                                                  | `true`              |
| `dovecot.livenessProbe.failureThreshold`      | Failure threshold for livenessProbe                                                   | `3`                 |
| `dovecot.livenessProbe.initialDelaySeconds`   | Initial delay seconds for livenessProbe                                               | `10`                |
| `dovecot.livenessProbe.periodSeconds`         | Period seconds for livenessProbe                                                      | `10`                |
| `dovecot.livenessProbe.successThreshold`      | Success threshold for livenessProbe                                                   | `1`                 |
| `dovecot.livenessProbe.timeoutSeconds`        | Timeout seconds for livenessProbe                                                     | `1`                 |
| `dovecot.readinessProbe.enabled`              | Enable readinessProbe                                                                 | `true`              |
| `dovecot.readinessProbe.initialDelaySeconds`  | Initial delay seconds for readinessProbe                                              | `10`                |
| `dovecot.readinessProbe.periodSeconds`        | Period seconds for readinessProbe                                                     | `10`                |
| `dovecot.readinessProbe.timeoutSeconds`       | Timeout seconds for readinessProbe                                                    | `1`                 |
| `dovecot.readinessProbe.failureThreshold`     | Failure threshold for readinessProbe                                                  | `3`                 |
| `dovecot.readinessProbe.successThreshold`     | Success threshold for readinessProbe                                                  | `1`                 |
| `dovecot.startupProbe.enabled`                | Enable startupProbe                                                                   | `false`             |
| `dovecot.startupProbe.initialDelaySeconds`    | Initial delay seconds for startupProbe                                                | `10`                |
| `dovecot.startupProbe.periodSeconds`          | Period seconds for startupProbe                                                       | `10`                |
| `dovecot.startupProbe.timeoutSeconds`         | Timeout seconds for startupProbe                                                      | `1`                 |
| `dovecot.startupProbe.failureThreshold`       | Failure threshold for startupProbe                                                    | `3`                 |
| `dovecot.startupProbe.successThreshold`       | Success threshold for startupProbe                                                    | `1`                 |
| `dovecot.podLabels`                           | Add extra labels to pod                                                               | `{}`                |
| `dovecot.podAnnotations`                      | Add extra annotations to the pod                                                      | `{}`                |
| `dovecot.nodeSelector`                        | Node labels selector for pod assignment                                               | `{}`                |
| `dovecot.initContainers`                      | Add additional init containers to the pod                                             | `[]`                |
| `dovecot.priorityClassName`                   | Pods' priorityClassName                                                               | `""`                |
| `dovecot.terminationGracePeriodSeconds`       | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `dovecot.affinity`                            | Affinity for dovecot pod assignment                                                   | `{}`                |
| `dovecot.tolerations`                         | Tolerations for pod assignment                                                        | `[]`                |
| `dovecot.revisionHistoryLimit`                | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `dovecot.hostAliases`                         | Pod pod host aliases                                                                  | `[]`                |
| `dovecot.schedulerName`                       | Name of the k8s scheduler (other than default)                                        | `""`                |
| `dovecot.service.annotations`                 | Admin service annotations                                                             | `{}`                |
| `dovecot.topologySpreadConstraints`           | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `dovecot.updateStrategy.type`                 | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `dovecot.extraEnvVars`                        | Extra environment variable to pass to the running container                           | `[]`                |
| `dovecot.extraEnvVarsCM`                      | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `dovecot.extraEnvVarsSecret`                  | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `dovecot.extraVolumeMounts`                   | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `dovecot.overrides`                           | Enable dovecot overrides                                                              | `{}`                |
| `rspamd_clamav_persistence.size`              | Size of the volume                                                                    | `20Gi`              |
| `rspamd_clamav_persistence.storageClass`      | Storage class of the volume                                                           | `""`                |
| `rspamd_clamav_persistence.accessMode`        | Access mode of the volume                                                             | `ReadWriteOnce`     |
| `rspamd_clamav_persistence.claimNameOverride` | Override the name of the PVC                                                          | `""`                |
| `rspamd_clamav_persistence.single_pvc`        | Use a single PVC for rspamd and clamav                                                | `false`             |
| `rspamd_clamav_persistence.annotations`       | Annotations for the PVC                                                               | `{}`                |

### rspamd parameters

| Name                                        | Description                                                                           | Value               |
| ------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `rspamd.logLevel`                           | Override default log level                                                            | `""`                |
| `rspamd.image.repository`                   | Pod image repository                                                                  | `mailu/rspamd`      |
| `rspamd.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `rspamd.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `rspamd.persistence.size`                   | Pod pvc size                                                                          | `1Gi`               |
| `rspamd.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `rspamd.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `rspamd.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `rspamd.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `rspamd.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `rspamd.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `rspamd.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `rspamd.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `rspamd.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `rspamd.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `rspamd.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `rspamd.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `rspamd.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `rspamd.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `rspamd.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `rspamd.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `rspamd.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `rspamd.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `rspamd.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `rspamd.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `rspamd.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `rspamd.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `5`                 |
| `rspamd.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `90`                |
| `rspamd.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `rspamd.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `rspamd.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `rspamd.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `rspamd.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `rspamd.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `rspamd.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `rspamd.affinity`                           | Affinity for rspamd pod assignment                                                    | `{}`                |
| `rspamd.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `rspamd.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `rspamd.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `rspamd.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `rspamd.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `rspamd.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `rspamd.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `rspamd.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `rspamd.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `rspamd.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `rspamd.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### clamav parameters

| Name                                        | Description                                                                           | Value               |
| ------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `clamav.enabled`                            | Enable ClamAV                                                                         | `true`              |
| `clamav.logLevel`                           | Override default log level                                                            | `""`                |
| `clamav.image.repository`                   | Pod image repository                                                                  | `mailu/clamav`      |
| `clamav.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `clamav.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `clamav.persistence.size`                   | Pod pvc size                                                                          | `2Gi`               |
| `clamav.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `clamav.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `clamav.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `clamav.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `clamav.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `clamav.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `clamav.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `clamav.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `clamav.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `clamav.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `clamav.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `clamav.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `clamav.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `clamav.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `clamav.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `clamav.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `clamav.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `clamav.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `clamav.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `clamav.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `clamav.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `clamav.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `5`                 |
| `clamav.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `60`                |
| `clamav.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `clamav.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `clamav.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `clamav.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `clamav.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `clamav.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `clamav.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `clamav.affinity`                           | Affinity for clamav pod assignment                                                    | `{}`                |
| `clamav.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `clamav.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `clamav.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `clamav.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `clamav.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `clamav.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `clamav.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `clamav.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `clamav.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `clamav.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `clamav.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### roundcube parameters

| Name                                           | Description                                                                           | Value               |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `roundcube.enabled`                            | Enable deployment of Roundcube webmail                                                | `true`              |
| `roundcube.uri`                                | URI to access Roundcube webmail                                                       | `/roundcube`        |
| `roundcube.logLevel`                           | Override default log level                                                            | `""`                |
| `roundcube.image.repository`                   | Pod image repository                                                                  | `mailu/roundcube`   |
| `roundcube.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `roundcube.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `roundcube.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `roundcube.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `roundcube.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `roundcube.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `roundcube.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `roundcube.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `roundcube.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `roundcube.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `roundcube.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `roundcube.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `roundcube.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `roundcube.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `roundcube.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `roundcube.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `roundcube.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `roundcube.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `roundcube.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `roundcube.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `roundcube.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `roundcube.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `roundcube.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `roundcube.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `roundcube.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `roundcube.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `roundcube.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `roundcube.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `roundcube.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `roundcube.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `roundcube.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `roundcube.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `roundcube.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `roundcube.affinity`                           | Affinity for roundcube pod assignment                                                 | `{}`                |
| `roundcube.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `roundcube.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `roundcube.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `roundcube.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `roundcube.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `roundcube.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `roundcube.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `roundcube.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `roundcube.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `roundcube.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `roundcube.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### webdav parameters

| Name                                        | Description                                                                           | Value               |
| ------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `webdav.enabled`                            | Enable deployment of WebDAV server (using Radicale)                                   | `false`             |
| `webdav.logLevel`                           | Override default log level                                                            | `""`                |
| `webdav.image.repository`                   | Pod image repository                                                                  | `mailu/radicale`    |
| `webdav.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `webdav.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `webdav.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `webdav.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `webdav.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `webdav.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `webdav.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `webdav.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `webdav.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `webdav.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `webdav.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `webdav.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `webdav.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `webdav.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `webdav.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `webdav.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `webdav.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `webdav.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `webdav.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `webdav.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `webdav.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `webdav.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `webdav.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `webdav.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `webdav.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `webdav.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `webdav.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `webdav.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `webdav.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `webdav.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `webdav.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `webdav.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `webdav.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `webdav.affinity`                           | Affinity for webdav pod assignment                                                    | `{}`                |
| `webdav.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `webdav.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `webdav.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `webdav.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `webdav.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `webdav.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `webdav.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `webdav.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `webdav.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `webdav.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `webdav.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

### fetchmail parameters

| Name                                           | Description                                                                           | Value               |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `fetchmail.enabled`                            | Enable deployment of fetchmail                                                        | `false`             |
| `fetchmail.delay`                              | Delay between fetchmail runs                                                          | `600`               |
| `fetchmail.logLevel`                           | Override default log level                                                            | `""`                |
| `fetchmail.image.repository`                   | Pod image repository                                                                  | `mailu/fetchmail`   |
| `fetchmail.image.tag`                          | Pod image tag (defaults to mailuVersion)                                              | `""`                |
| `fetchmail.image.pullPolicy`                   | Pod image pull policy                                                                 | `IfNotPresent`      |
| `fetchmail.persistence.size`                   | Pod pvc size                                                                          | `20Gi`              |
| `fetchmail.persistence.storageClass`           | Pod pvc storage class                                                                 | `""`                |
| `fetchmail.persistence.accessModes`            | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `fetchmail.persistence.claimNameOverride`      | Pod pvc name override                                                                 | `""`                |
| `fetchmail.persistence.annotations`            | Pod pvc annotations                                                                   | `{}`                |
| `fetchmail.resources.limits`                   | The resources limits for the container                                                | `{}`                |
| `fetchmail.resources.requests`                 | The requested resources for the container                                             | `{}`                |
| `fetchmail.livenessProbe.enabled`              | Enable livenessProbe                                                                  | `true`              |
| `fetchmail.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                   | `3`                 |
| `fetchmail.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                               | `10`                |
| `fetchmail.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                      | `10`                |
| `fetchmail.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                   | `1`                 |
| `fetchmail.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                     | `1`                 |
| `fetchmail.readinessProbe.enabled`             | Enable readinessProbe                                                                 | `true`              |
| `fetchmail.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                              | `10`                |
| `fetchmail.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                     | `10`                |
| `fetchmail.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                    | `1`                 |
| `fetchmail.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                  | `3`                 |
| `fetchmail.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                  | `1`                 |
| `fetchmail.startupProbe.enabled`               | Enable startupProbe                                                                   | `false`             |
| `fetchmail.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                | `10`                |
| `fetchmail.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                       | `10`                |
| `fetchmail.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                      | `1`                 |
| `fetchmail.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                    | `3`                 |
| `fetchmail.startupProbe.successThreshold`      | Success threshold for startupProbe                                                    | `1`                 |
| `fetchmail.podLabels`                          | Add extra labels to pod                                                               | `{}`                |
| `fetchmail.podAnnotations`                     | Add extra annotations to the pod                                                      | `{}`                |
| `fetchmail.nodeSelector`                       | Node labels selector for pod assignment                                               | `{}`                |
| `fetchmail.initContainers`                     | Add additional init containers to the pod                                             | `[]`                |
| `fetchmail.priorityClassName`                  | Pods' priorityClassName                                                               | `""`                |
| `fetchmail.terminationGracePeriodSeconds`      | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `fetchmail.affinity`                           | Affinity for fetchmail pod assignment                                                 | `{}`                |
| `fetchmail.tolerations`                        | Tolerations for pod assignment                                                        | `[]`                |
| `fetchmail.revisionHistoryLimit`               | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `fetchmail.hostAliases`                        | Pod pod host aliases                                                                  | `[]`                |
| `fetchmail.schedulerName`                      | Name of the k8s scheduler (other than default)                                        | `""`                |
| `fetchmail.service.annotations`                | Admin service annotations                                                             | `{}`                |
| `fetchmail.topologySpreadConstraints`          | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `fetchmail.updateStrategy.type`                | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `fetchmail.extraEnvVars`                       | Extra environment variable to pass to the running container                           | `[]`                |
| `fetchmail.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `fetchmail.extraEnvVarsSecret`                 | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `fetchmail.extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |

## Example values.yaml to get started

```yaml
domain: mail.mydomain.com
hostnames:
  - mail.mydomain.com
initialAccount:
  domain: mail.mydomain.com
  password: chang3m3!
  username: mailadmin
logLevel: INFO
mail:
  authRatelimit: 100/minute;3600/hour
  messageSizeLimitInMegabytes: 200
persistence:
  size: 100Gi
  storageClass: fast
secretKey: chang3m3!
```

## Persistence

### hostPath persistence

If `persistence.hostPath` is set, a path on the host is used for persistence. This overrides all other persistence options.

### PVC with existing claim

If `persistence.existingClaim` is set, not PVC is created and the PCV with the given name is being used.

### PVC with automatic provisioning

If neither `persistence.hostPath` nor `persistence.existingClaim` is set, a new PVC is created. The name of the claim is generated but it
can be overridden with `persistence.claimNameOverride`.

The `persistence.storageClass` is not set by default. It can be set to `-` to have an empty storageClassName or to anything else to use this name.

All pods are using the same PV. This is not a technical but a historical limitation which could be changed in the future. If you plan to
deploy to multiple nodes, ensure that you set `persistence.accessMode` to `ReadWriteMany`.

## Trouble shooting

### All services are running but authentication fails for webmail and imap

It's very likely that your PODs run on a different subnet than the default `10.42.0.0/16`. Set the `subnet` value to the correct subnet and try again.

## Deployment of DaemonSet for front nginx pod(s)

Depending on your environment you might want to shedule "only one pod" (`Deployment`) or "one pod per node" (`DaemonSet`) for the `front` nginx pod(s).

A `DaemonSet` can e.g. be usefull if you have multiple DNS entries / IPs in your MX record and want `front` to be reachable on every IP.

## Ingress

The default ingress is handled externally. In some situations, this is problematic, such as when webmail should be accessible
on the same address as the exposed ports. Kubernetes services cannot provide such capabilities without vendor-specific annotations.

By setting `ingress.externalIngress` to false, the internal NGINX instance provided by `front` will configure TLS according to
`ingress.tlsFlavor` and redirect `http` scheme connections to `https`.

CAUTION: This configuration exposes `/admin` to all clients with access to the web UI.

## CertManager

The default logic is to use CertManager to generate certificate for Mailu.

In some configuration you want to handle certificate generation and update another way, use `certmanager.use=false` to avoid the use of the CRD.

You will have to create and keep up-to-date your TLS keys. At the moment, this chart is looking for it under the `"mailu.fullname"-certificates` name in the namespace.

## Database

By default both, Mailu and RoundCube uses an embedded SQLite database.

The chart allows to use an embedded MySQL or external MySQL or PostgreSQL databases instead. It can be controlled by the following values:

### MySQL / MariaDB

In the sub-sections, we we use the reference "MySQL", it is meant for any MySQL-compatible database system (like MariaDB).

#### Using MySQL for Mailu

Set `database.type` to `mysql`.

The `database.mysql.database`, `database.mysql.user`, and `database.mysql.password` variables must also be set.

### Using MySQL for RoundCube

Set `database.roundcubeType` to `mysql`.

The `database.mysql.roundcubeDatabase`, `database.mysql.roundcubeUser`, and `database.mysql.roundcubePassword` variables must also be set.

### Using the internal MySQL database

The chart deploys an instance of MariaDB if either `database.type` or `database.roundcubeType` is set to `mysql` and the `database.mysql.host` is NOT set.

Mailu and RoundCube will use the same MariaDB instance. A database root password can be set with `database.mysql.rootPassword`. If not set, a random root password will be used.

### Using an external mysql database

An external mysql database can be used by setting `database.mysql.host`. The chart does not support different mysql hosts for mailu and dovecot. Using other mysql ports than the default 3306 port is also nur supported by the chart.

### PostgreSQL

PostgreSQL can be used as an external database management system for Mailu and Roundcube.

An external PostgreSQL database can be used by setting `database.postgresql.host`.

The chart does not support different PostgreSQL hosts for Mailu and RoundCube. Using other PostgreSQL ports than the default 5432 port is also not supported by the chart.

#### Using PostgreSQL for Mailu

Set `database.type` to `postgresql`.

The `database.postgresql.database`, `database.postgresql.user`, and `database.postgresql.password` chart values must also be set.

#### Using Postgresql for Roundcube

Set `database.roundcubeType` to `postgresql`.

The`database.postgresql.roundcubeDatabase`, `database.postgresql.roundcubeUser`, and `database.postgresql.roundcubePassword` must also be set.

## Timezone

By default, no timezone is set to the PODS, so logs and mail timestamps are all UTC. The option `timezone` allows to use specify a time zone to use (e.g. `Europe/Berlin`).

Note that this requires timezone data installed on the host filesystem that will be mounted into pods as localtime. When <https://github.com/Mailu/Mailu/issues/1154> is solved, the chart will be modified to use this solution instead of host files.

## Exposing mail ports to the public

There are several ways to expose mail ports to the public. If you do so, make sure you read and understand the warning above about open relays.

### Running on a single node with a public IP

This is the most straightforward way to run mailu. It can be used when the node where mailu (or at least the "front" POD) runs on a specific node that has a public ip address which is used for mail. All mail ports of the "front" POD will be simply exposed via the "hostPort" function.

To use this mode, set `front.hostPort.enabled` to `true` (which is the default). If your cluster has multiple nodes, you should use `front.nodeSelector` to bind the front container on the node where your public mail IP is located on.

### Running on bare metal with k3s and klipper-lb

If you run on bare metal with k3s (e.g by using k3os), you can use the build-in load balancer [klipper-lb](https://rancher.com/docs/k3s/latest/en/networking/#service-load-balancer). To expose mailu via loadBalancer, set:

- `front.hostPort.enabled`: `false`
- `externalService.enabled`: `true`
- `externalService.type`: `LoadBalancer`
- `externalService.externalTrafficPolicy`: `Local`

The [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) is important to preserve the client's source IP and avoid an open relay.

Please perform open relay tests after setup as described above!
