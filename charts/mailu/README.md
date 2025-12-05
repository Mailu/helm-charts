# mailu

![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fmailu.github.io%2Fhelm-charts%2Findex.yaml&query=%24.entries.mailu%5B%3A1%5D.version&style=flat-square&label=Version) ![AppVersion](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fmailu.github.io%2Fhelm-charts%2Findex.yaml&query=%24.entries.mailu%5B%3A1%5D.appVersion&style=flat-square&label=AppVersion)

This chart installs the Mailu mail system on Kubernetes

**Homepage:** <https://mailu.io>

## Compatibility

| Chart Version       | Mailu Version |
| ------------------- | ------------- |
| 0.0.x, 0.1.x, 0.2.x | 1.8           |
| 0.3.x               | 1.9.x         |
| 1.x.x               | 2.x           |
| 2.x.x               | >= 2024.06    |

Active development of this chart is only for the latest supported Mailu version.
Branches exists for older Mailu versions (e.g. old/mailu-1.8).

## Prerequisites

- Starting with version 1.9, you need a validating DNSSEC compatible resolver in order to run Mailu.
- a working HTTP/HTTPS ingress controller such as nginx or Traefik
- cert-manager v0.12 or higher installed and configured (including a working cert issuer) – otherwise you'll need to handle issuing certificates and providing the secret to Mailu yourself
- a node which has a publicly reachable static IP address, because mail service binds directly to the node's IP
- a hosting provider that allows inbound and outbound traffic on port 25
- Helm 3 (Helm 2 support is dropped with release 0.3.0)

| Repository                         | Name       | Version |
| ---------------------------------- | ---------- | ------- |
| https://charts.bitnami.com/bitnami | common     | 2.0.3   |
| https://charts.bitnami.com/bitnami | mariadb    | 11.3.\* |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.\* |
| https://charts.bitnami.com/bitnami | redis      | 17.3.\* |

### Warning about open relays

One of the biggest mistakes when running a mail server is a so-called "open relay".
In most cases, this kind of misconfiguration is caused by a badly configured load balancer that hides the originating IP address of an email.
This makes Mailu think that the email is coming from an internal address and it omits authentication and other checks.
As a result, your mail server can be abused to spread spam and will get blacklisted within hours.

It is very important to check whether your setup is an open relay at least:

- after installation
- any time you change network settings or load balancer configuration

The check is quite simple:

- watch the logs for the "mailu-front" pod
- browse to an open relay checker like <https://mxtoolbox.com/diagnostic.aspx>
- enter the hostname or IP address of your mail server and start the test

In the logs, you should see some message like

```bash
2021/10/26 21:23:25 [info] 12#12: *25691 client 18.205.72.90:56741 connected to 0.0.0.0:25
```

The IP address shown here must be a public IP address, i.e. not in any of the RFC 1918 subnets: `10.0.0.0/8`, `172.16.0.0/12`, or `192.168.0.0/16`

Also verify that the result of the check confirms that there is no open relay:

```bash
SMTP Open Relay OK - Not an open relay.
```

### Warning, this will not work on most cloud providers

- Google Cloud does not allow outgoing connections to connect to port 25, so
  [you will not be able to send mails with Mailu on Google Cloud](<https://googlecloudplatform.uservoice.com/forums/302595-compute-engine/suggestions/12422808-please-unblock-port-25-allow-outbound-mail-connec>)
- Many cloud providers don't assign fixed IPs to nodes directly. They use proxies or load balancers instead.
  While this works well with HTTP/HTTPs, on raw TCP connections (such as mail protocol connections) the originating IP gets lost.
  There's a so called "proxy protocol" as a solution for this limitation but that's not yet supported by Mailu (due to the lack of support in the nginx mail modules).
  Without the original IP information, a mail server will not work properly, or worse, become
  an open relay.
- If you'd like to run Mailu on Kubernetes, consider renting a cheap VPS to run Kubernetes on (e.g. using Rancher2).
  A good option for a hosting provider is [Hetzner Cloud VPS](<https://www.hetzner.com/cloud/>) (author's personal opinion).
- Please don't open issues in the bug tracker if your mail server is not working because your cloud provider blocks port 25 or hides source IP addresses behind a load balancer.

## Installation

- add the repository:

```bash
helm repo add mailu https://mailu.github.io/helm-charts/
```

- create a local values file:

```bash
helm show values mailu/mailu > my-values-file.yaml
```

Edit the `my-values-file.yaml` to reflect your environment.

- deploy the Helm chart:

```bash
helm install mailu mailu/mailu -n mailu-mailserver --values my-values-file.yaml
```

- check that the deployed pods are all running

### Uninstall

```bash
helm uninstall mailu --namespace=mailu-mailserver
```

## Parameters

### Global parameters

| Name                                                  | Description                                                                       | Value       |
| ----------------------------------------------------- | --------------------------------------------------------------------------------- | ----------- |
| `global.imageRegistry`                                | Global container image registry                                                   | `""`        |
| `global.imagePullSecrets`                             | Global container image pull secret                                                | `[]`        |
| `global.storageClass`                                 | Global storageClass to use for persistent volumes                                 | `""`        |
| `global.database.roundcube.database`                  | Name of the Roundcube database                                                    | `roundcube` |
| `global.database.roundcube.username`                  | Username to use for the Roundcube database                                        | `roundcube` |
| `global.database.roundcube.password`                  | Password to use for the Roundcube database                                        | `""`        |
| `global.database.roundcube.existingSecret`            | Name of an existing secret to use for the Roundcube database                      | `""`        |
| `global.database.roundcube.existingSecretPasswordKey` | Name of the key in the existing secret to use for the Roundcube database password | `""`        |

### Common parameters

| Name                | Description                                                                            | Value     |
| ------------------- | -------------------------------------------------------------------------------------- | --------- |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                   | `""`      |
| `nameOverride`      | String to partially override `mailu.fullname` include (will maintain the release name) | `""`      |
| `fullnameOverride`  | String to fully override `mailu.fullname` template                                     | `""`      |
| `commonLabels`      | Add labels to all the deployed resources                                               | `{}`      |
| `commonAnnotations` | Add annotations to all the deployed resources                                          | `{}`      |
| `tolerations`       | Tolerations for pod assignment                                                         | `[]`      |
| `affinity`          | Affinity for pod assignment                                                            | `{}`      |
| `imageRegistry`     | Container registry to use for all Mailu images                                         | `ghcr.io` |

### Mailu parameters

| Name                                          | Description                                                                                                                            | Value                                                                                                                                         |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `hostnames`                                   | List of hostnames to generate certificates and ingresses for. The first will be used as primary mail hostname.                         | `[]`                                                                                                                                          |
| `domain`                                      | Mail domain name. See https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames      | `""`                                                                                                                                          |
| `secretKey`                                   | The secret key is required for protecting authentication cookies and must be set individually for each deployment                      | `""`                                                                                                                                          |
| `existingSecret`                              | Name of the existing secret to retrieve the secretKey.                                                                                 | `""`                                                                                                                                          |
| `timezone`                                    | Timezone to use for the containers                                                                                                     | `Etc/UTC`                                                                                                                                     |
| `initialAccount.enabled`                      | Enable the creation of the initial account                                                                                             | `false`                                                                                                                                       |
| `initialAccount.username`                     | Username of the initial account                                                                                                        | `""`                                                                                                                                          |
| `initialAccount.domain`                       | Domain of the initial account                                                                                                          | `""`                                                                                                                                          |
| `initialAccount.password`                     | Password of the initial account; ignored if using existing secret; if empty, a random password will be generated and saved in a secret | `""`                                                                                                                                          |
| `initialAccount.existingSecret`               | Name of the existing secret to retrieve the initial account's password                                                                 | `""`                                                                                                                                          |
| `initialAccount.existingSecretPasswordKey`    | Name of the key in the existing secret to use for the initial account's password                                                       | `""`                                                                                                                                          |
| `initialAccount.mode`                         | How to treat the creationg of the initial account. Possible values: "create", "update" or "ifmissing"                                  | `update`                                                                                                                                      |
| `api.enabled`                                 | Enable the API interface                                                                                                               | `false`                                                                                                                                       |
| `api.token`                                   | Token to use for the API interface - if empty, a random token will be generated and saved in a secret                                  | `""`                                                                                                                                          |
| `api.existingSecret`                          | Name of the existing secret to retrieve the API token - if set, the token will be ignored                                              | `""`                                                                                                                                          |
| `api.existingSecretTokenKey`                  | Name of the key in the existing secret to use for the API token                                                                        | `api-token`                                                                                                                                   |
| `api.webPath`                                 | Path for the API interface                                                                                                             | `/api`                                                                                                                                        |
| `subnet`                                      | Change this if you're using different address ranges for pods (IPv4)                                                                   | `10.42.0.0/16`                                                                                                                                |
| `subnet6`                                     | Change this if you're using different address ranges for pods (IPv6)                                                                   | `""`                                                                                                                                          |
| `networkPolicy.enabled`                       | Enable network policy                                                                                                                  | `false`                                                                                                                                       |
| `networkPolicy.ingressController.namespace`   | Namespace where the ingress controller is deployed                                                                                     | `ingress-nginx`                                                                                                                               |
| `networkPolicy.ingressController.podSelector` | Selector for the ingress controller pods                                                                                               | `matchLabels:
  app.kubernetes.io/name: ingress-nginx
  app.kubernetes.io/instance: ingress-nginx
  app.kubernetes.io/component: controller
` |
| `networkPolicy.monitoring.namespace`          | Namespace where the monitoring pods are deployed                                                                                       | `monitoring`                                                                                                                                  |
| `networkPolicy.monitoring.podSelector`        | Selector for the monitoring pods                                                                                                       | `matchLabels:
  app.kubernetes.io/name: prometheus-agent
  app.kubernetes.io/instance: kps
`                                                  |
| `mailuVersion`                                | Override Mailu version to be deployed (tag of `mailu` images). Defaults to `Chart.AppVersion` - must be master or a version >= 2.0     | `""`                                                                                                                                          |
| `logLevel`                                    | default log level. can be overridden globally or per service                                                                           | `WARNING`                                                                                                                                     |
| `postmaster`                                  | local part of the postmaster email address (Mailu will use @$DOMAIN as domain part)                                                    | `postmaster`                                                                                                                                  |
| `recipientDelimiter`                          | The delimiter used to separate local part from extension in recipient addresses                                                        | `+`                                                                                                                                           |
| `dmarc.rua`                                   | Local part of the DMARC report email address (Mailu will use @$DOMAIN as domain part)                                                  | `""`                                                                                                                                          |
| `dmarc.ruf`                                   | Local part of the DMARC failure report email address (Mailu will use @$DOMAIN as domain part)                                          | `""`                                                                                                                                          |
| `limits.messageSizeLimitInMegabytes`          | Maximum size of an email in megabytes                                                                                                  | `50`                                                                                                                                          |
| `limits.authRatelimit.ip`                     | Sets the `AUTH_RATELIMIT_IP` environment variable in the `admin` pod                                                                   | `60/hour`                                                                                                                                     |
| `limits.authRatelimit.ipv4Mask`               | Sets the `AUTH_RATELIMIT_IP_V4_MASK` environment variable in the `admin` pod                                                           | `24`                                                                                                                                          |
| `limits.authRatelimit.ipv6Mask`               | Sets the `AUTH_RATELIMIT_IP_V6_MASK` environment variable in the `admin` pod                                                           | `56`                                                                                                                                          |
| `limits.authRatelimit.user`                   | Sets the `AUTH_RATELIMIT_USER` environment variable in the `admin` pod                                                                 | `100/day`                                                                                                                                     |
| `limits.authRatelimit.exemptionLength`        | Sets the `AUTH_RATELIMIT_EXEMPTION_LENGTH` environment variable in the `admin` pod                                                     | `86400`                                                                                                                                       |
| `limits.authRatelimit.exemption`              | Sets the `AUTH_RATELIMIT_EXEMPTION` environment variable in the `admin` pod                                                            | `""`                                                                                                                                          |
| `limits.messageRatelimit.value`               | Sets the `MESSAGE_RATELIMIT` environment variable in the `admin` pod                                                                   | `200/day`                                                                                                                                     |
| `limits.messageRatelimit.exemption`           | Sets the `MESSAGE_RATELIMIT_EXEMPTION` environment variable in the `admin` pod                                                         | `""`                                                                                                                                          |
| `externalRelay.host`                          | Hostname of the external relay                                                                                                         | `""`                                                                                                                                          |
| `externalRelay.username`                      | Username for the external relay                                                                                                        | `""`                                                                                                                                          |
| `externalRelay.password`                      | Password for the external relay                                                                                                        | `""`                                                                                                                                          |
| `externalRelay.existingSecret`                | Name of the secret containing the username and password for the external relay; if set, username and password will be ignored          | `""`                                                                                                                                          |
| `externalRelay.usernameKey`                   | Key in the secret containing the username for the external relay                                                                       | `relay-username`                                                                                                                              |
| `externalRelay.passwordKey`                   | Key in the secret containing the password for the external relay                                                                       | `relay-password`                                                                                                                              |
| `externalRelay.networks`                      | List of networks that are allowed to use Mailu as external relay                                                                       | `[]`                                                                                                                                          |
| `clusterDomain`                               | Kubernetes cluster domain name                                                                                                         | `cluster.local`                                                                                                                               |
| `credentialRounds`                            | Number of rounds to use for password hashing                                                                                           | `12`                                                                                                                                          |
| `sessionCookieSecure`                         | Controls the secure flag on the cookies of the administrative interface.                                                               | `true`                                                                                                                                        |
| `authRequireTokens`                           | Require tokens for authentication                                                                                                      | `false`                                                                                                                                       |
| `sessionTimeout`                              | Maximum amount of time in seconds between requests before a session is invalidated                                                     | `3600`                                                                                                                                        |
| `permanentSessionLifetime`                    | Maximum amount of time in seconds a session can be kept alive for if it hasn’t timed-out                                               | `2592000`                                                                                                                                     |
| `letsencryptShortchain`                       | Controls whether we send the ISRG Root X1 certificate in TLS handshakes.                                                               | `false`                                                                                                                                       |
| `customization.siteName`                      | Website name                                                                                                                           | `Mailu`                                                                                                                                       |
| `customization.website`                       | URL of the website                                                                                                                     | `https://mailu.io`                                                                                                                            |
| `customization.logoUrl`                       | Sets a URL for a custom logo. This logo replaces the Mailu logo in the topleft of the main admin interface.                            | `""`                                                                                                                                          |
| `customization.logoBackground`                | Sets a custom background colour for the brand logo in the top left of the main admin interface.                                        | `""`                                                                                                                                          |
| `welcomeMessage.enabled`                      | Enable welcome message                                                                                                                 | `true`                                                                                                                                        |
| `welcomeMessage.subject`                      | Subject of the welcome message                                                                                                         | `Welcome to Mailu`                                                                                                                            |
| `welcomeMessage.body`                         | Body of the welcome message                                                                                                            | `Welcome to Mailu, your new email service. Please change your password and update your profile.`                                              |
| `wildcardSenders`                             | List of user emails that can send emails from any address                                                                              | `[]`                                                                                                                                          |
| `tls.outboundLevel`                           | Sets the `OUTBOUND_TLS_LEVEL` environment variable                                                                                     | `""`                                                                                                                                          |
| `tls.deferOnError`                            | Sets the `DEFER_ON_TLS_ERROR` environment variable                                                                                     | `""`                                                                                                                                          |
| `tls.inboundEnforce`                          | Sets the `INBOUND_TLS_ENFORCE` environment variable                                                                                    | `""`                                                                                                                                          |

### Storage parameters

| Name                                                | Description                                                                                                                                                                                               | Value                             |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `externalDatabase.enabled`                          | Set to true to use an external database                                                                                                                                                                   | `false`                           |
| `externalDatabase.type`                             | Type of the external database for Mailu and Roundcube (`mysql`/`postgresql`)                                                                                                                              | `""`                              |
| `externalDatabase.host`                             | Hostname of the database                                                                                                                                                                                  | `""`                              |
| `externalDatabase.port`                             | Override for port of the database                                                                                                                                                                         | `""`                              |
| `externalDatabase.database`                         | Name of the database                                                                                                                                                                                      | `mailu`                           |
| `externalDatabase.username`                         | Username to use for the database                                                                                                                                                                          | `mailu`                           |
| `externalDatabase.password`                         | Password to use for the database                                                                                                                                                                          | `""`                              |
| `externalDatabase.existingSecret`                   | Name of the secret containing the database credentials                                                                                                                                                    | `""`                              |
| `externalDatabase.existingSecretDatabaseKey`        | Key in the secret containing the database name                                                                                                                                                            | `database`                        |
| `externalDatabase.existingSecretUsernameKey`        | Key in the secret containing the database username                                                                                                                                                        | `username`                        |
| `externalDatabase.existingSecretPasswordKey`        | Key in the secret containing the database password                                                                                                                                                        | `password`                        |
| `externalDatabase.appendix`                         | String appended to the SQLAlchemy URI                                                                                                                                                                     | `""`                              |
| `externalRedis.enabled`                             | Set to true to use an external Redis instance (ignored if `redis.enabled` is true)                                                                                                                        | `false`                           |
| `externalRedis.host`                                | Hostname of the external Redis instance                                                                                                                                                                   | `""`                              |
| `externalRedis.port`                                | Port of the external Redis instance                                                                                                                                                                       | `6379`                            |
| `externalRedis.adminQuotaDbId`                      | Redis database ID for the quota storage on the admin pod                                                                                                                                                  | `1`                               |
| `externalRedis.adminRateLimitDbId`                  | Redis database ID for the rate limit storage on the admin pod                                                                                                                                             | `2`                               |
| `externalRedis.rspamdDbId`                          | Redis database ID for the rspamd storage on the rspamd pod                                                                                                                                                | `0`                               |
| `database.mysql.roundcubePassword`                  | DEPRECATED - DO NOT USE: Password for the Roundcube database                                                                                                                                              | `""`                              |
| `database.postgresql.roundcubePassword`             | DEPRECATED - DO NOT USE: Password for the Roundcube database                                                                                                                                              | `""`                              |
| `mariadb.enabled`                                   | Enable MariaDB deployment                                                                                                                                                                                 | `false`                           |
| `mariadb.architecture`                              | MariaDB architecture. Allowed values: standalone or replication                                                                                                                                           | `standalone`                      |
| `mariadb.image.repository`                          | MariaDB image repository (using bitnamilegacy for now)                                                                                                                                                    | `bitnamilegacy/mariadb`           |
| `mariadb.auth.rootPassword`                         | Password for the `root` user. Ignored if existing secret is provided.                                                                                                                                     | `""`                              |
| `mariadb.auth.database`                             | Name for a custom database to create                                                                                                                                                                      | `mailu`                           |
| `mariadb.auth.username`                             | Name for a custom user to create                                                                                                                                                                          | `mailu`                           |
| `mariadb.auth.password`                             | Password for the new user. Ignored if existing secret is provided                                                                                                                                         | `""`                              |
| `mariadb.auth.existingSecret`                       | Use existing secret for password details (`auth.rootPassword`, `auth.password`, `auth.replicationPassword`                                                                                                | `""`                              |
| `mariadb.primary.persistence.enabled`               | Enable persistence using PVC                                                                                                                                                                              | `false`                           |
| `mariadb.primary.persistence.storageClass`          | PVC Storage Class for MariaDB volume                                                                                                                                                                      | `""`                              |
| `mariadb.primary.persistence.accessMode`            | PVC Access Mode for MariaDB volume                                                                                                                                                                        | `ReadWriteOnce`                   |
| `mariadb.primary.persistence.size`                  | PVC Storage Request for MariaDB volume                                                                                                                                                                    | `8Gi`                             |
| `mariadb.metrics.image.repository`                  | MariaDB metrics exporter image (using bitnamilegacy for now)                                                                                                                                              | `bitnamilegacy/mysqld-exporter`   |
| `mariadb.volumePermissions.image.repository`        | MariaDB volume permissions image (using bitnamilegacy for now)                                                                                                                                            | `bitnamilegacy/os-shell`          |
| `postgresql.enabled`                                | Enable PostgreSQL deployment                                                                                                                                                                              | `false`                           |
| `postgresql.architecture`                           | PostgreSQL architecture. Allowed values: standalone or replication                                                                                                                                        | `standalone`                      |
| `postgresql.image.repository`                       | PostgreSQL image repository (using bitnamilegacy for now)                                                                                                                                                 | `bitnamilegacy/postgresql`        |
| `postgresql.auth.enablePostgresUser`                | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user                                                                                                    | `true`                            |
| `postgresql.auth.postgresPassword`                  | Password for the "postgres" admin user. Ignored if `auth.existingSecret` with key `postgres-password` is provided                                                                                         | `changeme`                        |
| `postgresql.auth.username`                          | Name for a custom user to create                                                                                                                                                                          | `mailu`                           |
| `postgresql.auth.password`                          | Password for the custom user to create. Ignored if `auth.existingSecret` with key `password` is provided                                                                                                  | `""`                              |
| `postgresql.auth.database`                          | Name for a custom database to create                                                                                                                                                                      | `mailu`                           |
| `postgresql.auth.existingSecret`                    | Use existing secret for password details (`auth.postgresPassword`, `auth.password` will be ignored and picked up from this secret). The secret has to contain the keys `postgres-password` and `password` | `""`                              |
| `postgresql.auth.secretKeys.adminPasswordKey`       | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `postgres-password`               |
| `postgresql.auth.secretKeys.userPasswordKey`        | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `password`                        |
| `postgresql.auth.secretKeys.replicationPasswordKey` | Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.                                                                                            | `replication-password`            |
| `postgresql.primary.persistence.enabled`            | Enable persistence using PVC                                                                                                                                                                              | `false`                           |
| `postgresql.primary.persistence.storageClass`       | PVC Storage Class for PostgreSQL volume                                                                                                                                                                   | `""`                              |
| `postgresql.primary.persistence.accessMode`         | PVC Access Mode for PostgreSQL volume                                                                                                                                                                     | `ReadWriteOnce`                   |
| `postgresql.primary.persistence.size`               | PVC Storage Request for PostgreSQL volume                                                                                                                                                                 | `8Gi`                             |
| `postgresql.metrics.image.repository`               | PostgreSQL metrics exporter image (using bitnamilegacy for now)                                                                                                                                           | `bitnamilegacy/postgres-exporter` |
| `postgresql.volumePermissions.image.repository`     | PostgreSQL volume permissions image (using bitnamilegacy for now)                                                                                                                                         | `bitnamilegacy/os-shell`          |
| `persistence.single_pvc`                            | Setings for a single volume for all apps.                                                                                                                                                                 | `true`                            |
| `persistence.size`                                  | Size of the persistent volume claim (for single PVC)                                                                                                                                                      | `100Gi`                           |
| `persistence.accessModes`                           | Access mode of backing PVC (for single PVC)                                                                                                                                                               | `["ReadWriteOnce"]`               |
| `persistence.annotations`                           | Annotations for the PVC (for single PVC)                                                                                                                                                                  | `{}`                              |
| `persistence.hostPath`                              | Path to mount the volume at on the host                                                                                                                                                                   | `""`                              |
| `persistence.existingClaim`                         | Name of existing PVC (for single PVC)                                                                                                                                                                     | `""`                              |
| `persistence.storageClass`                          | Storage class of backing PVC (for single PVC)                                                                                                                                                             | `""`                              |
| `persistence.claimNameOverride`                     | Override the name of the PVC (for single PVC)                                                                                                                                                             | `""`                              |

### Ingress settings

| Name                                | Description                                                                                                                      | Value                    |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `ingress.enabled`                   | Enable external ingress                                                                                                          | `true`                   |
| `ingress.ingressClassName`          | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |
| `ingress.pathType`                  | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `ingress.apiVersion`                | Force Ingress API version (automatically detected if not set)                                                                    | `""`                     |
| `ingress.path`                      | Default path for the ingress record                                                                                              | `/`                      |
| `ingress.annotations`               | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                       | Enable TLS configuration for the hosts defined at `hostnames` parameter                                                          | `true`                   |
| `ingress.existingSecret`            | Name of an existing Secret containing the TLS certificates for the Ingress                                                       | `""`                     |
| `ingress.selfSigned`                | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                  |
| `ingress.extraHosts`                | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                     |
| `ingress.extraPaths`                | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `ingress.extraTls`                  | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                     |
| `ingress.secrets`                   | Custom TLS certificates as secrets                                                                                               | `[]`                     |
| `ingress.extraRules`                | Additional rules to be covered with this ingress record                                                                          | `[]`                     |
| `ingress.realIpHeader`              | Sets the value of `REAL_IP_HEADER` environment variable in the `front` pod                                                       | `X-Forwarded-For`        |
| `ingress.realIpFrom`                | Sets the value of `REAL_IP_FROM` environment variable in the `front` pod                                                         | `""`                     |
| `ingress.tlsFlavorOverride`         | Overrides the value of `TLS_FLAVOR` environment variable in the `front` pod                                                      | `""`                     |
| `ingress.proxyProtocol.pop3`        | Enable PROXY protocol for POP3 (110/tcp)                                                                                         | `false`                  |
| `ingress.proxyProtocol.pop3s`       | Enable PROXY protocol for POP3S (995/tcp)                                                                                        | `false`                  |
| `ingress.proxyProtocol.imap`        | Enable PROXY protocol for IMAP (143/tcp)                                                                                         | `false`                  |
| `ingress.proxyProtocol.imaps`       | Enable PROXY protocol for IMAPS (993/tcp)                                                                                        | `false`                  |
| `ingress.proxyProtocol.smtp`        | Enable PROXY protocol for SMTP (25/tcp)                                                                                          | `false`                  |
| `ingress.proxyProtocol.smtps`       | Enable PROXY protocol for SMTPS (465/tcp)                                                                                        | `false`                  |
| `ingress.proxyProtocol.submission`  | Enable PROXY protocol for Submission (587/tcp)                                                                                   | `false`                  |
| `ingress.proxyProtocol.manageSieve` | Enable PROXY protocol for ManageSieve (4190/tcp)                                                                                 | `false`                  |

### Proxy auth configuration

| Name                  | Description                                                          | Value          |
| --------------------- | -------------------------------------------------------------------- | -------------- |
| `proxyAuth.whitelist` | Comma separated list of CIDRs of proxies to trust for authentication | `""`           |
| `proxyAuth.header`    | HTTP header containing the email address of the user to authenticate | `X-Auth-Email` |
| `proxyAuth.create`    | Whether non-existing accounts should be auto-created                 | `false`        |

### Frontend load balancer for non-HTTP(s) services

| Name                                          | Description                                                                           | Value           |
| --------------------------------------------- | ------------------------------------------------------------------------------------- | --------------- |
| `front.logLevel`                              | Override default log level                                                            | `""`            |
| `front.image.repository`                      | Pod image repository                                                                  | `mailu/nginx`   |
| `front.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`            |
| `front.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`  |
| `front.hostPort.enabled`                      | Expose front mail ports via hostPort                                                  | `true`          |
| `front.externalService.enabled`               | Expose front mail ports via external service (ClusterIP or LoadBalancer)              | `false`         |
| `front.externalService.type`                  | Service type (ClusterIP or LoadBalancer)                                              | `ClusterIP`     |
| `front.externalService.externalTrafficPolicy` | Service externalTrafficPolicy (Cluster or Local)                                      | `Local`         |
| `front.externalService.externalIPs`           | Service externalIPs                                                                   | `[]`            |
| `front.externalService.loadBalancerIP`        | Service loadBalancerIP                                                                | `""`            |
| `front.externalService.annotations`           | Service annotations                                                                   | `{}`            |
| `front.externalService.labels`                | Service labels                                                                        | `{}`            |
| `front.externalService.ports.pop3`            | Expose POP3 port - 110/tcp                                                            | `false`         |
| `front.externalService.ports.pop3s`           | Expose POP3 port (TLS) - 995/tcp                                                      | `true`          |
| `front.externalService.ports.imap`            | Expose IMAP port - 143/tcp                                                            | `false`         |
| `front.externalService.ports.imaps`           | Expose IMAP port (TLS) - 993/tcp                                                      | `true`          |
| `front.externalService.ports.smtp`            | Expose SMTP port - 25/tcp                                                             | `true`          |
| `front.externalService.ports.smtps`           | Expose SMTP port (TLS) - 465/tcp                                                      | `true`          |
| `front.externalService.ports.submission`      | Expose Submission port - 587/tcp                                                      | `false`         |
| `front.externalService.ports.manageSieve`     | Expose ManageSieve port - 4190/tcp                                                    | `true`          |
| `front.externalService.nodePorts.pop3`        | NodePort to use for POP3 (defaults to 110/tcp)                                        | `110`           |
| `front.externalService.nodePorts.pop3s`       | NodePort to use for POP3 (TLS) (defaults to 995/tcp)                                  | `995`           |
| `front.externalService.nodePorts.imap`        | NodePort to use for IMAP (defaults to 143/tcp)                                        | `143`           |
| `front.externalService.nodePorts.imaps`       | NodePort to use for IMAP (TLS) (defaults to 993/tcp)                                  | `993`           |
| `front.externalService.nodePorts.smtp`        | NodePort to use for SMTP (defaults to 25/tcp)                                         | `25`            |
| `front.externalService.nodePorts.smtps`       | NodePort to use for SMTP (TLS) (defaults to 465/tcp)                                  | `465`           |
| `front.externalService.nodePorts.submission`  | NodePort to use for Submission (defaults to 587/tcp)                                  | `587`           |
| `front.externalService.nodePorts.manageSieve` | NodePort to use for ManageSieve (defaults to 4190/tcp)                                | `4190`          |
| `front.kind`                                  | Kind of resource to create for the front (`Deployment` or `DaemonSet`)                | `Deployment`    |
| `front.replicaCount`                          | Number of front replicas to deploy (only for `Deployment` kind)                       | `1`             |
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
| `front.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`         |
| `front.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`          |
| `front.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`         |
| `front.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`          |
| `front.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`         |
| `front.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`             |
| `front.affinity`                              | Affinity for front pod assignment                                                     | `{}`            |
| `front.tolerations`                           | Tolerations for pod assignment                                                        | `[]`            |
| `front.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`             |
| `front.hostAliases`                           | Pod pod host aliases                                                                  | `[]`            |
| `front.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`            |
| `front.service.annotations`                   | Admin service annotations                                                             | `{}`            |
| `front.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`            |
| `front.updateStrategy.type`                   | Strategy to use to update Pods                                                        | `RollingUpdate` |
| `front.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`            |
| `front.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`            |
| `front.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`            |
| `front.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`            |
| `front.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`            |
| `front.extraContainers`                       | Add additional containers to the pod                                                  | `[]`            |
| `front.overrides`                             | Enable front overrides                                                                | `{}`            |

### Admin parameters

| Name                                          | Description                                                                                   | Value               |
| --------------------------------------------- | --------------------------------------------------------------------------------------------- | ------------------- |
| `admin.enabled`                               | Enable access to the admin interface                                                          | `true`              |
| `admin.uri`                                   | URI to access the admin interface                                                             | `/admin`            |
| `admin.logLevel`                              | Override default log level                                                                    | `""`                |
| `admin.image.repository`                      | Pod image repository                                                                          | `mailu/admin`       |
| `admin.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)               | `""`                |
| `admin.image.pullPolicy`                      | Pod image pull policy                                                                         | `IfNotPresent`      |
| `admin.persistence.size`                      | Pod pvc size                                                                                  | `20Gi`              |
| `admin.persistence.storageClass`              | Pod pvc storage class                                                                         | `""`                |
| `admin.persistence.accessModes`               | Pod pvc access modes                                                                          | `["ReadWriteOnce"]` |
| `admin.persistence.claimNameOverride`         | Pod pvc name override                                                                         | `""`                |
| `admin.persistence.annotations`               | Pod pvc annotations                                                                           | `{}`                |
| `admin.persistence.existingClaim`             | Pod pvc existing claim name                                                                   | `""`                |
| `admin.resources.limits`                      | The resources limits for the container                                                        | `{}`                |
| `admin.resources.requests`                    | The requested resources for the container                                                     | `{}`                |
| `admin.livenessProbe.enabled`                 | Enable livenessProbe                                                                          | `true`              |
| `admin.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                           | `3`                 |
| `admin.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                       | `10`                |
| `admin.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                              | `10`                |
| `admin.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                           | `1`                 |
| `admin.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                             | `1`                 |
| `admin.readinessProbe.enabled`                | Enable readinessProbe                                                                         | `true`              |
| `admin.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                      | `10`                |
| `admin.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                             | `10`                |
| `admin.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                            | `1`                 |
| `admin.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                          | `3`                 |
| `admin.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                          | `1`                 |
| `admin.startupProbe.enabled`                  | Enable startupProbe                                                                           | `false`             |
| `admin.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                        | `10`                |
| `admin.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                               | `10`                |
| `admin.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                              | `1`                 |
| `admin.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                            | `3`                 |
| `admin.startupProbe.successThreshold`         | Success threshold for startupProbe                                                            | `1`                 |
| `admin.podLabels`                             | Add extra labels to pod                                                                       | `{}`                |
| `admin.podAnnotations`                        | Add extra annotations to the pod                                                              | `{}`                |
| `admin.nodeSelector`                          | Node labels selector for pod assignment                                                       | `{}`                |
| `admin.initContainers`                        | Add additional init containers to the pod                                                     | `[]`                |
| `admin.priorityClassName`                     | Pods' priorityClassName                                                                       | `""`                |
| `admin.podSecurityContext.enabled`            | Enabled pods' Security Context                                                                | `false`             |
| `admin.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                            | `1001`              |
| `admin.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                          | `false`             |
| `admin.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                    | `1001`              |
| `admin.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                                 | `false`             |
| `admin.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                                     | `2`                 |
| `admin.dnsPolicy`                             | DNS Policy of the admin pod (`Default`, `ClusterFirst`, `ClusterFirstWithHostNet` and `None`) | `""`                |
| `admin.dnsConfig`                             | DNS settings for the admin pod                                                                | `{}`                |
| `admin.affinity`                              | Affinity for admin pod assignment                                                             | `{}`                |
| `admin.tolerations`                           | Tolerations for pod assignment                                                                | `[]`                |
| `admin.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                          | `3`                 |
| `admin.hostAliases`                           | Pod pod host aliases                                                                          | `[]`                |
| `admin.schedulerName`                         | Name of the k8s scheduler (other than default)                                                | `""`                |
| `admin.service.annotations`                   | Admin service annotations                                                                     | `{}`                |
| `admin.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                                | `[]`                |
| `admin.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                                       | `RollingUpdate`     |
| `admin.extraEnvVars`                          | Extra environment variable to pass to the running container                                   | `[]`                |
| `admin.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod         | `""`                |
| `admin.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod            | `""`                |
| `admin.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                          | `[]`                |
| `admin.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                            | `[]`                |
| `admin.extraContainers`                       | Add additional containers to the pod                                                          | `[]`                |

### Redis parameters

| Name                                       | Description                                                         | Value                          |
| ------------------------------------------ | ------------------------------------------------------------------- | ------------------------------ |
| `redis.enabled`                            | Enable redis deployment through the redis subchart                  | `true`                         |
| `redis.architecture`                       | Redis architecture. Allowed values: `standalone` or `replication`   | `standalone`                   |
| `redis.image.repository`                   | Redis image repository (using bitnamilegacy for now)                | `bitnamilegacy/redis`          |
| `redis.auth.enabled`                       | DON'T CHANGE THIS VALUE. Mailu doesn't support Redis authentication | `false`                        |
| `redis.master.enabled`                     | DON'T CHANGE THIS VALUE. Enable redis master                        | `true`                         |
| `redis.master.count`                       | Number of redis master replicas                                     | `1`                            |
| `redis.master.persistence.enabled`         | Enable persistence using Persistent Volume Claims                   | `true`                         |
| `redis.master.persistence.size`            | Pod pvc size                                                        | `8Gi`                          |
| `redis.master.persistence.storageClass`    | Pod pvc storage class                                               | `""`                           |
| `redis.master.persistence.accessModes`     | Pod pvc access modes                                                | `["ReadWriteOnce"]`            |
| `redis.master.persistence.annotations`     | Pod pvc annotations                                                 | `{}`                           |
| `redis.master.persistence.existingClaim`   | Pod pvc existing claim; necessary if using single_pvc               | `""`                           |
| `redis.master.persistence.subPath`         | Subpath in PVC; necessary if using single_pvc (set it to `redis`)   | `""`                           |
| `redis.replica.count`                      | Number of redis replicas (only if `redis.architecture=replication`) | `0`                            |
| `redis.sentinel.image.repository`          | Redis Sentinel image (using bitnamilegacy for now)                  | `bitnamilegacy/redis-sentinel` |
| `redis.metrics.image.repository`           | Redis metrics exporter image (using bitnamilegacy for now)          | `bitnamilegacy/redis-exporter` |
| `redis.volumePermissions.image.repository` | Redis volume permissions image (using bitnamilegacy for now)        | `bitnamilegacy/os-shell`       |
| `redis.kubectl.image.repository`           | Redis kubectl image (using bitnamilegacy for now)                   | `bitnamilegacy/kubectl`        |
| `redis.sysctl.image.repository`            | Redis sysctl image (using bitnamilegacy for now)                    | `bitnamilegacy/os-shell`       |

### Postfix parameters

| Name                                            | Description                                                                           | Value               |
| ----------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `postfix.logLevel`                              | Override default log level                                                            | `""`                |
| `postfix.image.repository`                      | Pod image repository                                                                  | `mailu/postfix`     |
| `postfix.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                |
| `postfix.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`      |
| `postfix.persistence.size`                      | Pod pvc size                                                                          | `20Gi`              |
| `postfix.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                |
| `postfix.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `postfix.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                |
| `postfix.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                |
| `postfix.persistence.existingClaim`             | Pod pvc existing claim name                                                           | `""`                |
| `postfix.resources.limits`                      | The resources limits for the container                                                | `{}`                |
| `postfix.resources.requests`                    | The requested resources for the container                                             | `{}`                |
| `postfix.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`              |
| `postfix.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                 |
| `postfix.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                |
| `postfix.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                |
| `postfix.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                 |
| `postfix.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                 |
| `postfix.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`              |
| `postfix.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                |
| `postfix.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                |
| `postfix.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                 |
| `postfix.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                 |
| `postfix.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                 |
| `postfix.startupProbe.enabled`                  | Enable startupProbe                                                                   | `true`              |
| `postfix.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                |
| `postfix.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                |
| `postfix.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `1`                 |
| `postfix.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `30`                |
| `postfix.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                 |
| `postfix.podLabels`                             | Add extra labels to pod                                                               | `{}`                |
| `postfix.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                |
| `postfix.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                |
| `postfix.initContainers`                        | Add additional init containers to the pod                                             | `[]`                |
| `postfix.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                |
| `postfix.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`             |
| `postfix.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`              |
| `postfix.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`             |
| `postfix.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`              |
| `postfix.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`             |
| `postfix.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `postfix.affinity`                              | Affinity for postfix pod assignment                                                   | `{}`                |
| `postfix.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                |
| `postfix.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `postfix.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                |
| `postfix.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                |
| `postfix.service.annotations`                   | Admin service annotations                                                             | `{}`                |
| `postfix.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `postfix.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `postfix.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                |
| `postfix.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `postfix.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `postfix.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `postfix.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                |
| `postfix.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                |
| `postfix.overrides`                             | Enable postfix overrides                                                              | `{}`                |

### Dovecot parameters

| Name                                            | Description                                                                           | Value               |
| ----------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `dovecot.enabled`                               | Enable dovecot                                                                        | `true`              |
| `dovecot.logLevel`                              | Override default log level                                                            | `""`                |
| `dovecot.image.repository`                      | Pod image repository                                                                  | `mailu/dovecot`     |
| `dovecot.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                |
| `dovecot.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`      |
| `dovecot.persistence.size`                      | Pod pvc size                                                                          | `20Gi`              |
| `dovecot.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                |
| `dovecot.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `dovecot.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                |
| `dovecot.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                |
| `dovecot.persistence.existingClaim`             | Pod pvc existing claim name                                                           | `""`                |
| `dovecot.resources.limits`                      | The resources limits for the container                                                | `{}`                |
| `dovecot.resources.requests`                    | The requested resources for the container                                             | `{}`                |
| `dovecot.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`              |
| `dovecot.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                 |
| `dovecot.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                |
| `dovecot.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                |
| `dovecot.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                 |
| `dovecot.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `10`                |
| `dovecot.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`              |
| `dovecot.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                |
| `dovecot.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                |
| `dovecot.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `10`                |
| `dovecot.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                 |
| `dovecot.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                 |
| `dovecot.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`             |
| `dovecot.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                |
| `dovecot.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                |
| `dovecot.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `10`                |
| `dovecot.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `3`                 |
| `dovecot.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                 |
| `dovecot.podLabels`                             | Add extra labels to pod                                                               | `{}`                |
| `dovecot.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                |
| `dovecot.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                |
| `dovecot.initContainers`                        | Add additional init containers to the pod                                             | `[]`                |
| `dovecot.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                |
| `dovecot.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`             |
| `dovecot.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`              |
| `dovecot.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`             |
| `dovecot.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`              |
| `dovecot.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`             |
| `dovecot.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `dovecot.affinity`                              | Affinity for dovecot pod assignment                                                   | `{}`                |
| `dovecot.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                |
| `dovecot.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `dovecot.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                |
| `dovecot.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                |
| `dovecot.service.annotations`                   | Admin service annotations                                                             | `{}`                |
| `dovecot.serviceMonitor.enabled`                | If true, a serviceMonitor will be created for Dovecot                                 | `false`             |
| `dovecot.serviceMonitor.annotations`            | Dovecot serviceMonitor annotations                                                    | `{}`                |
| `dovecot.serviceMonitor.interval`               | Dovecot serviceMonitor scrape interval                                                | `""`                |
| `dovecot.serviceMonitor.metricRelabelings`      | MetricRelabelConfigs to apply to samples after scraping, but before ingestion.        | `[]`                |
| `dovecot.serviceMonitor.relabelings`            | RelabelConfigs to apply to samples before scraping                                    | `[]`                |
| `dovecot.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `dovecot.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `dovecot.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                |
| `dovecot.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `dovecot.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `dovecot.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `dovecot.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                |
| `dovecot.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                |
| `dovecot.overrides`                             | Enable dovecot overrides                                                              | `{}`                |
| `dovecot.compression`                           | Maildir compression algorithm (gz, bz2, lz4, zstd)                                    | `""`                |
| `dovecot.compressionLevel`                      | Maildir compression level (1-9)                                                       | `6`                 |

### rspamd parameters

| Name                                           | Description                                                                           | Value               |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `rspamd.enabled`                               | Enable rspamd                                                                         | `true`              |
| `rspamd.overrides`                             | Enable rspamd overrides                                                               | `{}`                |
| `rspamd.antivirusAction`                       | Action to take when an virus is detected. Possible values: `reject` or `discard`      | `discard`           |
| `rspamd.logLevel`                              | Override default log level                                                            | `""`                |
| `rspamd.image.repository`                      | Pod image repository                                                                  | `mailu/rspamd`      |
| `rspamd.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                |
| `rspamd.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`      |
| `rspamd.persistence.size`                      | Pod pvc size                                                                          | `1Gi`               |
| `rspamd.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                |
| `rspamd.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `rspamd.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                |
| `rspamd.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                |
| `rspamd.persistence.existingClaim`             | Pod pvc existing claim name                                                           | `""`                |
| `rspamd.resources.limits`                      | The resources limits for the container                                                | `{}`                |
| `rspamd.resources.requests`                    | The requested resources for the container                                             | `{}`                |
| `rspamd.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`              |
| `rspamd.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                 |
| `rspamd.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                |
| `rspamd.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                |
| `rspamd.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                 |
| `rspamd.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                 |
| `rspamd.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`              |
| `rspamd.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                |
| `rspamd.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                |
| `rspamd.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                 |
| `rspamd.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                 |
| `rspamd.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                 |
| `rspamd.startupProbe.enabled`                  | Enable startupProbe                                                                   | `true`              |
| `rspamd.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                |
| `rspamd.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                |
| `rspamd.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `5`                 |
| `rspamd.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `90`                |
| `rspamd.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                 |
| `rspamd.podLabels`                             | Add extra labels to pod                                                               | `{}`                |
| `rspamd.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                |
| `rspamd.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                |
| `rspamd.initContainers`                        | Add additional init containers to the pod                                             | `[]`                |
| `rspamd.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                |
| `rspamd.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`             |
| `rspamd.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`              |
| `rspamd.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`             |
| `rspamd.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`              |
| `rspamd.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`             |
| `rspamd.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `rspamd.affinity`                              | Affinity for rspamd pod assignment                                                    | `{}`                |
| `rspamd.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                |
| `rspamd.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `rspamd.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                |
| `rspamd.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                |
| `rspamd.service.annotations`                   | Rspamd service annotations                                                            | `{}`                |
| `rspamd.serviceMonitor.enabled`                | If true, a serviceMonitor will be created for Rspamd                                  | `false`             |
| `rspamd.serviceMonitor.annotations`            | Rspamd serviceMonitor annotations                                                     | `{}`                |
| `rspamd.serviceMonitor.interval`               | Rspamd serviceMonitor scrape interval                                                 | `""`                |
| `rspamd.serviceMonitor.metricRelabelings`      | MetricRelabelConfigs to apply to samples after scraping, but before ingestion.        | `[]`                |
| `rspamd.serviceMonitor.relabelings`            | RelabelConfigs to apply to samples before scraping                                    | `[]`                |
| `rspamd.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `rspamd.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `rspamd.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                |
| `rspamd.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `rspamd.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `rspamd.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `rspamd.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                |
| `rspamd.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                |

### clamav parameters

| Name                                           | Description                                                                           | Value                                                                         |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `clamav.enabled`                               | Enable ClamAV                                                                         | `true`                                                                        |
| `clamav.logLevel`                              | Override default log level                                                            | `""`                                                                          |
| `clamav.image.repository`                      | Pod image repository                                                                  | `clamav/clamav-debian`                                                        |
| `clamav.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `1.4@sha256:c5bbda3191b7265ce4c92e7d2ae4d8fa58f14c0fd6598731aff4beb33f474902` |
| `clamav.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`                                                                |
| `clamav.image.registry`                        | Pod image registry (specific for ClamAV as it is not part of the Mailu organization)  | `docker.io`                                                                   |
| `clamav.persistence.enabled`                   | Enable persistence using PVC                                                          | `true`                                                                        |
| `clamav.persistence.size`                      | Pod pvc size                                                                          | `2Gi`                                                                         |
| `clamav.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                                                                          |
| `clamav.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]`                                                           |
| `clamav.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                                                                          |
| `clamav.persistence.labels`                    | Pod pvc labels                                                                        | `{}`                                                                          |
| `clamav.persistence.selector`                  | Additional labels to match for the PVC                                                | `{}`                                                                          |
| `clamav.persistence.dataSource`                | Custom PVC data source                                                                | `{}`                                                                          |
| `clamav.persistence.existingClaim`             | Use a existing PVC which must be created manually before bound                        | `""`                                                                          |
| `clamav.resources.limits`                      | The resources limits for the container                                                | `{}`                                                                          |
| `clamav.resources.requests`                    | The requested resources for the container                                             | `{}`                                                                          |
| `clamav.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`                                                                        |
| `clamav.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `5`                                                                           |
| `clamav.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                                                                          |
| `clamav.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                                                                          |
| `clamav.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                                                                           |
| `clamav.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                                                                           |
| `clamav.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`                                                                        |
| `clamav.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                                                                          |
| `clamav.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                                                                          |
| `clamav.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                                                                           |
| `clamav.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                                                                           |
| `clamav.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                                                                           |
| `clamav.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`                                                                       |
| `clamav.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                                                                          |
| `clamav.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                                                                          |
| `clamav.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `5`                                                                           |
| `clamav.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `60`                                                                          |
| `clamav.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                                                                           |
| `clamav.podLabels`                             | Add extra labels to pod                                                               | `{}`                                                                          |
| `clamav.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                                                                          |
| `clamav.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                                                                          |
| `clamav.initContainers`                        | Add additional init containers to the pod                                             | `[]`                                                                          |
| `clamav.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                                                                          |
| `clamav.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`                                                                       |
| `clamav.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`                                                                        |
| `clamav.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`                                                                       |
| `clamav.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`                                                                        |
| `clamav.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`                                                                       |
| `clamav.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                                                                           |
| `clamav.affinity`                              | Affinity for clamav pod assignment                                                    | `{}`                                                                          |
| `clamav.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                                                                          |
| `clamav.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                                                                          |
| `clamav.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                                                                          |
| `clamav.service.annotations`                   | Admin service annotations                                                             | `{}`                                                                          |
| `clamav.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                                                                          |
| `clamav.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`                                                               |
| `clamav.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                                                                          |
| `clamav.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                                                                          |
| `clamav.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                                                                          |
| `clamav.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                                                                          |
| `clamav.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                                                                          |
| `clamav.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                                                                          |

### webmail parameters

| Name                                            | Description                                                                           | Value                                                                             |
| ----------------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `webmail.enabled`                               | Enable deployment of webmail                                                          | `true`                                                                            |
| `webmail.uri`                                   | URI to access webmail                                                                 | `/webmail`                                                                        |
| `webmail.type`                                  | Type of webmail to deploy (`roundcube` or `snappymail`)                               | `roundcube`                                                                       |
| `webmail.roundcubePlugins`                      | List of Roundcube plugins to enable                                                   | `["archive","zipdownload","markasjunk","managesieve","enigma","carddav","mailu"]` |
| `webmail.logLevel`                              | Override default log level                                                            | `""`                                                                              |
| `webmail.image.repository`                      | Pod image repository                                                                  | `mailu/webmail`                                                                   |
| `webmail.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                                                                              |
| `webmail.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`                                                                    |
| `webmail.persistence.size`                      | Pod pvc size                                                                          | `20Gi`                                                                            |
| `webmail.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                                                                              |
| `webmail.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]`                                                               |
| `webmail.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                                                                              |
| `webmail.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                                                                              |
| `webmail.persistence.existingClaim`             | Pod pvc existing claim name                                                           | `""`                                                                              |
| `webmail.resources.limits`                      | The resources limits for the container                                                | `{}`                                                                              |
| `webmail.resources.requests`                    | The requested resources for the container                                             | `{}`                                                                              |
| `webmail.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`                                                                            |
| `webmail.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                                                                               |
| `webmail.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                                                                              |
| `webmail.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                                                                              |
| `webmail.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                                                                               |
| `webmail.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                                                                               |
| `webmail.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`                                                                            |
| `webmail.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                                                                              |
| `webmail.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                                                                              |
| `webmail.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                                                                               |
| `webmail.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                                                                               |
| `webmail.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                                                                               |
| `webmail.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`                                                                           |
| `webmail.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                                                                              |
| `webmail.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                                                                              |
| `webmail.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `1`                                                                               |
| `webmail.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `3`                                                                               |
| `webmail.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                                                                               |
| `webmail.podLabels`                             | Add extra labels to pod                                                               | `{}`                                                                              |
| `webmail.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                                                                              |
| `webmail.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                                                                              |
| `webmail.initContainers`                        | Add additional init containers to the pod                                             | `[]`                                                                              |
| `webmail.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                                                                              |
| `webmail.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`                                                                           |
| `webmail.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`                                                                            |
| `webmail.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`                                                                           |
| `webmail.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`                                                                            |
| `webmail.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`                                                                           |
| `webmail.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                                                                               |
| `webmail.affinity`                              | Affinity for webmail pod assignment                                                   | `{}`                                                                              |
| `webmail.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                                                                              |
| `webmail.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                                                                               |
| `webmail.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                                                                              |
| `webmail.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                                                                              |
| `webmail.service.annotations`                   | Admin service annotations                                                             | `{}`                                                                              |
| `webmail.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                                                                              |
| `webmail.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`                                                                   |
| `webmail.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                                                                              |
| `webmail.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                                                                              |
| `webmail.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                                                                              |
| `webmail.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                                                                              |
| `webmail.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                                                                              |
| `webmail.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                                                                              |

### webdav parameters

| Name                                           | Description                                                                           | Value               |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `webdav.enabled`                               | Enable deployment of WebDAV server (using Radicale)                                   | `false`             |
| `webdav.logLevel`                              | Override default log level                                                            | `""`                |
| `webdav.image.repository`                      | Pod image repository                                                                  | `mailu/radicale`    |
| `webdav.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                |
| `webdav.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`      |
| `webdav.persistence.size`                      | Pod pvc size                                                                          | `20Gi`              |
| `webdav.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                |
| `webdav.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `webdav.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                |
| `webdav.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                |
| `webdav.resources.limits`                      | The resources limits for the container                                                | `{}`                |
| `webdav.resources.requests`                    | The requested resources for the container                                             | `{}`                |
| `webdav.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`              |
| `webdav.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                 |
| `webdav.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                |
| `webdav.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                |
| `webdav.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                 |
| `webdav.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                 |
| `webdav.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`              |
| `webdav.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                |
| `webdav.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                |
| `webdav.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                 |
| `webdav.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                 |
| `webdav.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                 |
| `webdav.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`             |
| `webdav.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                |
| `webdav.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                |
| `webdav.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `1`                 |
| `webdav.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `3`                 |
| `webdav.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                 |
| `webdav.podLabels`                             | Add extra labels to pod                                                               | `{}`                |
| `webdav.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                |
| `webdav.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                |
| `webdav.initContainers`                        | Add additional init containers to the pod                                             | `[]`                |
| `webdav.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                |
| `webdav.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`             |
| `webdav.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`              |
| `webdav.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`             |
| `webdav.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`              |
| `webdav.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`             |
| `webdav.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `webdav.affinity`                              | Affinity for webdav pod assignment                                                    | `{}`                |
| `webdav.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                |
| `webdav.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `webdav.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                |
| `webdav.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                |
| `webdav.service.annotations`                   | Admin service annotations                                                             | `{}`                |
| `webdav.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `webdav.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `webdav.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                |
| `webdav.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `webdav.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `webdav.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `webdav.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                |
| `webdav.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                |

### fetchmail parameters

| Name                                              | Description                                                                           | Value               |
| ------------------------------------------------- | ------------------------------------------------------------------------------------- | ------------------- |
| `fetchmail.enabled`                               | Enable deployment of fetchmail                                                        | `false`             |
| `fetchmail.delay`                                 | Delay between fetchmail runs                                                          | `600`               |
| `fetchmail.logLevel`                              | Override default log level                                                            | `""`                |
| `fetchmail.image.repository`                      | Pod image repository                                                                  | `mailu/fetchmail`   |
| `fetchmail.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`                |
| `fetchmail.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`      |
| `fetchmail.persistence.size`                      | Pod pvc size                                                                          | `20Gi`              |
| `fetchmail.persistence.storageClass`              | Pod pvc storage class                                                                 | `""`                |
| `fetchmail.persistence.accessModes`               | Pod pvc access modes                                                                  | `["ReadWriteOnce"]` |
| `fetchmail.persistence.claimNameOverride`         | Pod pvc name override                                                                 | `""`                |
| `fetchmail.persistence.annotations`               | Pod pvc annotations                                                                   | `{}`                |
| `fetchmail.resources.limits`                      | The resources limits for the container                                                | `{}`                |
| `fetchmail.resources.requests`                    | The requested resources for the container                                             | `{}`                |
| `fetchmail.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`              |
| `fetchmail.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`                 |
| `fetchmail.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`                |
| `fetchmail.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`                |
| `fetchmail.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`                 |
| `fetchmail.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `1`                 |
| `fetchmail.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`              |
| `fetchmail.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`                |
| `fetchmail.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`                |
| `fetchmail.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `1`                 |
| `fetchmail.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`                 |
| `fetchmail.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`                 |
| `fetchmail.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`             |
| `fetchmail.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`                |
| `fetchmail.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`                |
| `fetchmail.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `1`                 |
| `fetchmail.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `3`                 |
| `fetchmail.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`                 |
| `fetchmail.podLabels`                             | Add extra labels to pod                                                               | `{}`                |
| `fetchmail.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`                |
| `fetchmail.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`                |
| `fetchmail.initContainers`                        | Add additional init containers to the pod                                             | `[]`                |
| `fetchmail.priorityClassName`                     | Pods' priorityClassName                                                               | `""`                |
| `fetchmail.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`             |
| `fetchmail.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`              |
| `fetchmail.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`             |
| `fetchmail.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`              |
| `fetchmail.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`             |
| `fetchmail.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`                 |
| `fetchmail.affinity`                              | Affinity for fetchmail pod assignment                                                 | `{}`                |
| `fetchmail.tolerations`                           | Tolerations for pod assignment                                                        | `[]`                |
| `fetchmail.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`                 |
| `fetchmail.hostAliases`                           | Pod pod host aliases                                                                  | `[]`                |
| `fetchmail.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`                |
| `fetchmail.service.annotations`                   | Admin service annotations                                                             | `{}`                |
| `fetchmail.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`                |
| `fetchmail.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`     |
| `fetchmail.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`                |
| `fetchmail.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`                |
| `fetchmail.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`                |
| `fetchmail.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`                |
| `fetchmail.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`                |
| `fetchmail.extraContainers`                       | Add additional containers to the pod                                                  | `[]`                |

### OLETools parameters

| Name                                             | Description                                                                           | Value            |
| ------------------------------------------------ | ------------------------------------------------------------------------------------- | ---------------- |
| `oletools.enabled`                               | Enable OLETools                                                                       | `true`           |
| `oletools.logLevel`                              | Override default log level                                                            | `""`             |
| `oletools.image.repository`                      | Pod image repository                                                                  | `mailu/oletools` |
| `oletools.image.tag`                             | Pod image tag (defaults to `mailuVersion` if set, otherwise `Chart.AppVersion`)       | `""`             |
| `oletools.image.pullPolicy`                      | Pod image pull policy                                                                 | `IfNotPresent`   |
| `oletools.resources.limits`                      | The resources limits for the container                                                | `{}`             |
| `oletools.resources.requests`                    | The requested resources for the container                                             | `{}`             |
| `oletools.livenessProbe.enabled`                 | Enable livenessProbe                                                                  | `true`           |
| `oletools.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                   | `3`              |
| `oletools.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                               | `10`             |
| `oletools.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                      | `10`             |
| `oletools.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                   | `1`              |
| `oletools.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                     | `5`              |
| `oletools.readinessProbe.enabled`                | Enable readinessProbe                                                                 | `true`           |
| `oletools.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                              | `10`             |
| `oletools.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                     | `10`             |
| `oletools.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                    | `5`              |
| `oletools.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                  | `3`              |
| `oletools.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                  | `1`              |
| `oletools.startupProbe.enabled`                  | Enable startupProbe                                                                   | `false`          |
| `oletools.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                | `10`             |
| `oletools.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                       | `10`             |
| `oletools.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                      | `5`              |
| `oletools.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                    | `3`              |
| `oletools.startupProbe.successThreshold`         | Success threshold for startupProbe                                                    | `1`              |
| `oletools.podLabels`                             | Add extra labels to pod                                                               | `{}`             |
| `oletools.podAnnotations`                        | Add extra annotations to the pod                                                      | `{}`             |
| `oletools.nodeSelector`                          | Node labels selector for pod assignment                                               | `{}`             |
| `oletools.initContainers`                        | Add additional init containers to the pod                                             | `[]`             |
| `oletools.priorityClassName`                     | Pods' priorityClassName                                                               | `""`             |
| `oletools.podSecurityContext.enabled`            | Enabled pods' Security Context                                                        | `false`          |
| `oletools.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                    | `1001`           |
| `oletools.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                  | `false`          |
| `oletools.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                            | `1001`           |
| `oletools.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                         | `false`          |
| `oletools.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                             | `2`              |
| `oletools.affinity`                              | Affinity for oletools pod assignment                                                  | `{}`             |
| `oletools.tolerations`                           | Tolerations for pod assignment                                                        | `[]`             |
| `oletools.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                  | `3`              |
| `oletools.hostAliases`                           | Pod pod host aliases                                                                  | `[]`             |
| `oletools.schedulerName`                         | Name of the k8s scheduler (other than default)                                        | `""`             |
| `oletools.service.annotations`                   | oletools service annotations                                                          | `{}`             |
| `oletools.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                        | `[]`             |
| `oletools.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                               | `RollingUpdate`  |
| `oletools.extraEnvVars`                          | Extra environment variable to pass to the running container                           | `[]`             |
| `oletools.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod | `""`             |
| `oletools.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod    | `""`             |
| `oletools.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                  | `[]`             |
| `oletools.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                    | `[]`             |
| `oletools.extraContainers`                       | Add additional containers to the pod                                                  | `[]`             |

### Tika parameters

| Name                                         | Description                                                                                     | Value                                                                                  |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `tika.enabled`                               | Enable tika                                                                                     | `true`                                                                                 |
| `tika.logLevel`                              | Override default log level                                                                      | `""`                                                                                   |
| `tika.languages`                             | Array of languages to enable (sets the FULL_TEXT_SEARCH environment variable); "off" to disable | `["en"]`                                                                               |
| `tika.image.repository`                      | Pod image repository                                                                            | `apache/tika`                                                                          |
| `tika.image.tag`                             | Pod image tag                                                                                   | `3.2.3.0-full@sha256:21d8052de04e491ccf66e8680ade4da6f3d453a56d59f740b4167e54167219b7` |
| `tika.image.pullPolicy`                      | Pod image pull policy                                                                           | `IfNotPresent`                                                                         |
| `tika.image.registry`                        | Pod image registry (specific for Tika as it is not part of the Mailu organization)              | `docker.io`                                                                            |
| `tika.resources.limits`                      | The resources limits for the container                                                          | `{}`                                                                                   |
| `tika.resources.requests`                    | The requested resources for the container                                                       | `{}`                                                                                   |
| `tika.livenessProbe.enabled`                 | Enable livenessProbe                                                                            | `true`                                                                                 |
| `tika.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                             | `3`                                                                                    |
| `tika.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                         | `10`                                                                                   |
| `tika.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                | `10`                                                                                   |
| `tika.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                             | `1`                                                                                    |
| `tika.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                               | `5`                                                                                    |
| `tika.readinessProbe.enabled`                | Enable readinessProbe                                                                           | `true`                                                                                 |
| `tika.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                        | `10`                                                                                   |
| `tika.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                               | `10`                                                                                   |
| `tika.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                              | `5`                                                                                    |
| `tika.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                            | `3`                                                                                    |
| `tika.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                            | `1`                                                                                    |
| `tika.startupProbe.enabled`                  | Enable startupProbe                                                                             | `false`                                                                                |
| `tika.startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                          | `10`                                                                                   |
| `tika.startupProbe.periodSeconds`            | Period seconds for startupProbe                                                                 | `10`                                                                                   |
| `tika.startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                                | `5`                                                                                    |
| `tika.startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                              | `3`                                                                                    |
| `tika.startupProbe.successThreshold`         | Success threshold for startupProbe                                                              | `1`                                                                                    |
| `tika.podLabels`                             | Add extra labels to pod                                                                         | `{}`                                                                                   |
| `tika.podAnnotations`                        | Add extra annotations to the pod                                                                | `{}`                                                                                   |
| `tika.nodeSelector`                          | Node labels selector for pod assignment                                                         | `{}`                                                                                   |
| `tika.initContainers`                        | Add additional init containers to the pod                                                       | `[]`                                                                                   |
| `tika.priorityClassName`                     | Pods' priorityClassName                                                                         | `""`                                                                                   |
| `tika.podSecurityContext.enabled`            | Enabled pods' Security Context                                                                  | `false`                                                                                |
| `tika.podSecurityContext.fsGroup`            | Set pods' Security Context fsGroup                                                              | `1001`                                                                                 |
| `tika.containerSecurityContext.enabled`      | Enabled containers' Security Context                                                            | `false`                                                                                |
| `tika.containerSecurityContext.runAsUser`    | Set containers' Security Context runAsUser                                                      | `1001`                                                                                 |
| `tika.containerSecurityContext.runAsNonRoot` | Set container's Security Context runAsNonRoot                                                   | `false`                                                                                |
| `tika.terminationGracePeriodSeconds`         | In seconds, time given to the pod to terminate gracefully                                       | `2`                                                                                    |
| `tika.affinity`                              | Affinity for tika pod assignment                                                                | `{}`                                                                                   |
| `tika.tolerations`                           | Tolerations for pod assignment                                                                  | `[]`                                                                                   |
| `tika.revisionHistoryLimit`                  | Configure the revisionHistoryLimit of the deployment                                            | `3`                                                                                    |
| `tika.hostAliases`                           | Pod pod host aliases                                                                            | `[]`                                                                                   |
| `tika.schedulerName`                         | Name of the k8s scheduler (other than default)                                                  | `""`                                                                                   |
| `tika.service.annotations`                   | tika service annotations                                                                        | `{}`                                                                                   |
| `tika.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                                  | `[]`                                                                                   |
| `tika.updateStrategy.type`                   | Can be set to RollingUpdate or OnDelete                                                         | `RollingUpdate`                                                                        |
| `tika.extraEnvVars`                          | Extra environment variable to pass to the running container                                     | `[]`                                                                                   |
| `tika.extraEnvVarsCM`                        | Name of existing ConfigMap containing extra environment variables to mount in the pod           | `""`                                                                                   |
| `tika.extraEnvVarsSecret`                    | Name of existing Secret containing extra environment variables to mount in the pod              | `""`                                                                                   |
| `tika.extraVolumeMounts`                     | Optionally specify extra list of additional volumeMounts for the pod                            | `[]`                                                                                   |
| `tika.extraVolumes`                          | Optionally specify extra list of additional volumes for the pod(s)                              | `[]`                                                                                   |
| `tika.extraContainers`                       | Add additional containers to the pod                                                            | `[]`                                                                                   |


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
limits:
  authRatelimit:
    ip: 100/minute;3600/hour
    user: 100/day
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

If `persistence.existingClaim` is set, no PVC is created and the existing PVC with the given name is being used.

This can be configured on an individual basis for each Mailu component as well.

### PVC with automatic provisioning

If neither `persistence.hostPath` nor `persistence.existingClaim` is set, a new PVC is created. The name of the claim is generated but it
can be overridden with `persistence.claimNameOverride`.

The `persistence.storageClass` is not set by default. It can be set to `-` to have an empty storageClassName or to anything else depending on your setup.

If you use only one PVC for all components and you have multiple nodes, ensure that you set `persistence.accessMode` to `ReadWriteMany` (and that your storage class supports it).

## Troubleshooting

### All services are running but authentication fails for webmail and imap

It's very likely that your PODs run on a different subnet than the default `10.42.0.0/16`. Set the `subnet` value to the correct subnet and try again.

**Warning:** For security reasons, make sure that the `subnet` value is scoped only to the resources that belongs to your cluster. Do not use a subnet that is too large as any IP within the `subnet` would have extended rights to send emails, bypassing some security controls and potentially making your installation an open relay.

## Deployment of DaemonSet for front nginx pod(s)

Depending on your environment you might want to shedule "only one pod" (`Deployment`) or "one pod per node" (`DaemonSet`) for the `front` nginx pod(s).

A `DaemonSet` can e.g. be useful if you have multiple DNS entries / IPs in your MX record and want `front` to be reachable on every IP.

This can be set with the `front.kind` value.

Beware that if using a `DaemonSet` you'll need a storage class that supports `ReadWriteMany` access mode.

## Ingress

The default ingress is handled externally. In some situations, this is problematic, such as when webmail should be accessible
on the same address as the exposed ports. Kubernetes services cannot provide such capabilities without vendor-specific annotations.

By setting `ingress.enabled` to false, the internal NGINX instance provided by `front` will configure TLS according to
`ingress.tlsFlavorOverride` and redirect `http` scheme connections to `https`.

CAUTION: This configuration exposes `/admin` to all clients with access to the web UI.

## Cert Manager

The default logic is to use Cert Manager to generate certificate for Mailu via Ingress annotations (`ingress.annotations={}`).

In some configuration you want to handle certificate generation and update another way, use `ingress.existingSecret=NAME_OF_EXISTING_SECRET` to let the Chart know where to find certificates managed externally.

You will have to create and keep up-to-date your TLS keys.

## Database

By default both, Mailu and RoundCube uses an embedded SQLite database.

The chart allows to deploy a MariaDB or a PostgresQL database.

You can also make use of an existing database by setting the correct under `externalDatabase`.

### Embedded MariaDB / MySQL

This chart can deploy a MariaDB instance (using Bitnami's Helm chart dependency) and configure it for Mailu to use it.

In order to do so, set `mariadb.enabled` to `true`.

The `root` and `mailu` passwords will be automatically generated by default and stored in a secret.

Make sure to also set `mariadb.primary.persistence.enabled` to `true` and configure it accordingly.

See [Bitnami's MariaDB Helm chart](https://artifacthub.io/packages/helm/bitnami/mariadb) for more configuration options (to be configured under the `mailu` key in your `values.yaml` file).

### Embedded Postgresql

This chart can deploy a Postgresql instance (using Bitnami's Helm chart dependency) and configure it for Mailu to use it.

In order to do so, set `postgresql.enabled` to `true`.

The `postgres` and `mailu` passwords will be automatically generated by default and stored in a secret.

Make sure to also set `postgresql.primary.persistence.enabled` to `true` and configure it accordingly.

See [Bitnami's Postgresql Helm chart](https://artifacthub.io/packages/helm/bitnami/postgresql) for more configuration options (to be configured under the `mailu` key in your `values.yaml` file).

### Using an external database

An external MariaDB / MySQL or Postgresql database can be used by setting `externalDatabase.enabled` to `true`.

The connection settings to the external database needs to be configured under `externalDatabase`.

### Roundcube's database

The roundcube database settings can be moified via `global.database.roundcube` (database name, username, password).

## Timezone

By default, no timezone is set to the PODS, so logs and mail timestamps are all UTC. The option `timezone` allows to use specify a time zone to use (e.g. `Europe/Berlin`).

Note that this requires timezone data installed on the host filesystem that will be mounted into pods as localtime. When <https://github.com/Mailu/Mailu/issues/1154> is solved, the chart will be modified to use this solution instead of host files.

## Exposing mail ports to the public

There are several ways to expose mail ports to the public. If you do so, make sure you read and understand the warning above about open relays.

### Running on a single node with a public IP

This is the most straightforward way to run Mailu. It can be used when the node where Mailu (or at least the "front" POD) runs on a specific node that has a public IP address which is used for mail. All mail ports of the "front" POD will be simply exposed via the "hostPort" function.

To use this mode, set `front.hostPort.enabled` to `true` (which is the default). If your cluster has multiple nodes, you should use `front.nodeSelector` to bind the front container on the node where your public mail IP is located on.

### Running on bare metal with k3s and klipper-lb

If you run on bare metal with k3s (e.g by using k3os), you can use the built-in load balancer [klipper-lb](https://rancher.com/docs/k3s/latest/en/networking/#service-load-balancer). To expose Mailu via loadBalancer, set:

- `front.hostPort.enabled`: `false`
- `externalService.enabled`: `true`
- `externalService.type`: `LoadBalancer`
- `externalService.externalTrafficPolicy`: `Local`

The [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) is important to preserve the client's source IP and avoid an open relay.

Please perform open relay tests after setup as described above!

## Environment variables mapping

The table below lists the environment variables that will be passed to the pods and their respective configuration path in the `values.yaml` file.

| Mailu env var                     | `values.yaml` config path              | Comment                                                    | Default value (Mailu 'docker' version)                   | Helm default value                                                                               |
| --------------------------------- | -------------------------------------- | ---------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `ADMIN`                           | `admin.enabled`                        |                                                            | `none`                                                   | `true`                                                                                           |
| `ANTIVIRUS_ACTION`                | `rspamd.antivirusAction`               |                                                            | `discard`                                                | `discard`                                                                                        |
| `AUTH_RATELIMIT_EXEMPTION_LENGTH` | `limits.authRatelimit.exemptionLength` |                                                            | `86400`                                                  | `86400`                                                                                          |
| `AUTH_RATELIMIT_EXEMPTION`        | `limits.authRatelimit.exemption`       |                                                            | ``                                                       | ``                                                                                               |
| `AUTH_RATELIMIT_IP`               | `limits.authRatelimit.ip`              |                                                            | `60/hour`                                                | `60/hour`                                                                                        |
| `AUTH_RATELIMIT_IP_V4_MASK`       | `limits.authRatelimit.ipv4Mask`        |                                                            | `24`                                                     | `24`                                                                                             |
| `AUTH_RATELIMIT_IP_V6_MASK`       | `limits.authRatelimit.ipv6Mask`        |                                                            | `56`                                                     | `56`                                                                                             |
| `AUTH_RATELIMIT_USER`             | `limits.authRatelimit.user`            |                                                            | `100/day`                                                | `100/day`                                                                                        |
| `BABEL_DEFAULT_LOCALE`            | -                                      |                                                            | `en`                                                     | `en`                                                                                             |
| `BABEL_DEFAULT_TIMEZONE`          | -                                      |                                                            | `UTC`                                                    | `UTC`                                                                                            |
| `BOOTSTRAP_SERVE_LOCAL`           | -                                      |                                                            | `True`                                                   | `True`                                                                                           |
| `CREDENTIAL_ROUNDS`               | `credentialRounds`                     |                                                            | `12`                                                     | `12`                                                                                             |
| `DB_FLAVOR`                       |                                        | Managed by Helm chart                                      | None                                                     |                                                                                                  |
| `DB_HOST`                         |                                        | Managed by Helm chart                                      | database                                                 |                                                                                                  |
| `DB_NAME`                         |                                        | Managed by Helm chart                                      | mailu                                                    |                                                                                                  |
| `DB_PW`                           |                                        | Managed by Helm chart                                      | None                                                     |                                                                                                  |
| `DB_USER`                         |                                        | Managed by Helm chart                                      | mailu                                                    |                                                                                                  |
| `DEBUG_ASSETS`                    | -                                      |                                                            | ``                                                       |                                                                                                  |
| `DEBUG`                           | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `DEBUG_PROFILER`                  | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `DEBUG_TB_INTERCEPT_REDIRECTS`    | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `DEFAULT_QUOTA`                   | -                                      |                                                            | `1000000000`                                             | `1000000000`                                                                                     |
| `DEFAULT_SPAM_THRESHOLD`          | -                                      |                                                            | `80`                                                     | `80`                                                                                             |
| `DEFER_ON_TLS_ERROR`              | -                                      |                                                            | `True`                                                   | `true`                                                                                           |
| `DISABLE_STATISTICS`              | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `DKIM_PATH`                       | -                                      |                                                            | `/dkim/{domain}.{selector}.key`                          | `/dkim/{domain}.{selector}.key`                                                                  |
| `DKIM_SELECTOR`                   | -                                      |                                                            | `dkim`                                                   | `dkim`                                                                                           |
| `DMARC_RUA`                       | `dmarc.rua`                            |                                                            | `none`                                                   | `none`                                                                                           |
| `DMARC_RUF`                       | `dmarc.ruf`                            |                                                            | `none`                                                   | `none`                                                                                           |
| `DOCKER_SOCKET`                   | -                                      | Not set in Helm chart                                      | `unix:///var/run/docker.sock`                            | -                                                                                                |
| `DOMAIN`                          | `domain`                               |                                                            | `mailu.io`                                               | _unset_                                                                                          |
| `DOMAIN_REGISTRATION`             | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `FETCHMAIL_ENABLED`               | `fetchmail.enabled`                    |                                                            | `False`                                                  | `false`                                                                                          |
| `HOSTNAMES`                       | `hostnames`                            | Use an array in Helm values instead of a string            | `mail.mailu.io,alternative.mailu.io,yetanother.mailu.io` | `[]`                                                                                             |
| `INBOUND_TLS_ENFORCE`             | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `INSTANCE_ID_PATH`                | -                                      |                                                            | `/data/instance`                                         | `/data/instance`                                                                                 |
| `KUBERNETES_INGRESS`              | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `LOG_LEVEL`                       | `logLevel`                             | Can be overriden for each pod through `COMPONENT.logLevel` | `WARNING`                                                | `WARNING`                                                                                        |
| `LOGO_BACKGROUND`                 | `customization.logoBackground`         |                                                            | `None`                                                   | `none`                                                                                           |
| `LOGO_URL`                        | `customization.logoUrl`                |                                                            | `None`                                                   | `none`                                                                                           |
| `MEMORY_SESSIONS`                 | `ingress.enabled`                      |                                                            | `False`                                                  | `true`                                                                                           |
| `MESSAGE_RATELIMIT_EXEMPTION`     | `limits.messageRatelimit.exemption`    |                                                            | ``                                                       | ``                                                                                               |
| `MESSAGE_RATELIMIT`               | `limits.messageRatelimit.value`        |                                                            | `200/day`                                                | `200/day`                                                                                        |
| `PERMANENT_SESSION_LIFETIME`      | `permanentSessionLifetime`             |                                                            | `30*24*3600`                                             | `2592000`                                                                                        |
| `POSTMASTER`                      | `postmaster`                           |                                                            | `postmaster`                                             | `postmaster`                                                                                     |
| `PROXY_AUTH_CREATE`               | `proxyAuth.create`                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `PROXY_AUTH_HEADER`               | `proxyAuth.header`                                      |                                                            | `X-Auth-Email`                                           | `X-Auth-Email`                                                                                   |
| `PROXY_AUTH_WHITELIST`            | `proxyAuth.whitelist`                                      |                                                            | ``                                                       | ``                                                                                               |
| `RATELIMIT_STORAGE_URL`           | -                                      | Managed by Helm chart                                      | ``                                                       |                                                                                                  |
| `RECAPTCHA_PRIVATE_KEY`           | -                                      |                                                            | ``                                                       | ``                                                                                               |
| `RECAPTCHA_PUBLIC_KEY`            | -                                      |                                                            | ``                                                       | ``                                                                                               |
| `REAL_IP_FROM`                    | `ingress.realIpFrom`                   |                                                            | ``                                                       | `0.0.0.0/0`                                                                                      |
| `REAL_IP_HEADER`                  | `ingress.realIpHeader`                 |                                                            | ``                                                       | `X-Forwarded-For`                                                                                |
| `RECIPIENT_DELIMITER`             | `recipientDelimiter`                   |                                                            | ``                                                       | `+`                                                                                              |
| `REJECT_UNLISTED_RECIPIENT`       | -                                      |                                                            | `yes`                                                    | `yes`                                                                                            |
| `RELAYHOST`                       | `externalRealy.host`                   |                                                            | ``                                                       | ``                                                                                               |
| `RELAYNETS`                       | `externalRealy.networks`               |                                                            | ``                                                       | ``                                                                                               |
| `ROUNDCUBE_DB_FLAVOR`             | -                                      | Managed by Helm chart                                      | `sqlite`                                                 | ``                                                                                               |
| `SECRET_KEY`                      | `secretKey` or `existingSecret`        | Auto-generated if not provided or empty                    | `changeMe`                                               | _auto-generated_                                                                                 |
| `SESSION_COOKIE_SECURE`           | `sessionCookieSecure`                  |                                                            | `None`                                                   | `true`                                                                                           |
| `SESSION_KEY_BITS`                | -                                      |                                                            | `128`                                                    | `128`                                                                                            |
| `SESSION_TIMEOUT`                 | `sessionTimeout`                       |                                                            | `3600`                                                   | `3600`                                                                                           |
| `SITENAME`                        | `customization.siteName`               |                                                            | `Mailu`                                                  | `Mailu`                                                                                          |
| `SQLALCHEMY_DATABASE_URI`         | -                                      |                                                            | `sqlite:////data/main.db`                                | `sqlite:////data/main.db`                                                                        |
| `SQLALCHEMY_TRACK_MODIFICATIONS`  | -                                      |                                                            | `False`                                                  | `false`                                                                                          |
| `SQLITE_DATABASE_FILE`            | -                                      |                                                            | `data/main.db`                                           | `data/main.db`                                                                                   |
| `STATS_ENDPOINT`                  | -                                      |                                                            | `19.{}.stats.mailu.io`                                   | `19.{}.stats.mailu.io`                                                                           |
| `SUBNET6`                         | `subnet6`                              | _warning: IPv6 support with Kubernetes is untested_        | `None`                                                   | `none`                                                                                           |
| `SUBNET`                          | `subnet`                               |                                                            | `192.168.203.0/24`                                       | `10.42.0.0/16`                                                                                   |
| `TEMPLATES_AUTO_RELOAD`           | -                                      |                                                            | `True`                                                   | `True`                                                                                           |
| `TLS_FLAVOR`                      | `ingress.tlsFlavorOverride`            |                                                            | `cert`                                                   | `cert`                                                                                           |
| `TLS_PERMISSIVE`                  | -                                      |                                                            | `True`                                                   | `True`                                                                                           |
| `TZ`                              | `timezone`                             |                                                            | `Etc/UTC`                                                | `Etc/UTC`                                                                                        |
| `WEB_ADMIN`                       | `admin.uri`                            |                                                            | `/admin`                                                 | `/admin`                                                                                         |
| `WEBMAIL`                         | `webmail.type`                         |                                                            | `none`                                                   | `roundcube`                                                                                      |
| `WEBSITE`                         | `customization.website`                |                                                            | `https://mailu.io`                                       | `https://mailu.io`                                                                               |
| `WEB_WEBMAIL`                     | `webmail.uri`                          |                                                            | `/webmail`                                               | `/webmail`                                                                                       |
| `WELCOME`                         | `welcomeMessage.enabled`               |                                                            | `False`                                                  | `false`                                                                                          |
| `WELCOME_BODY`                    | `welcomeMessage.body`                  |                                                            | `Dummy welcome body`                                     | `Welcome to Mailu, your new email service. Please change your password and update your profile.` |
| `WELCOME_SUBJECT`                 | `welcomeMessage.subject`               |                                                            | `Dummy welcome topic`                                    | `Welcome to Mailu`                                                                               |
| `WILDCARD_SENDERS`                | -                                      |                                                            | ``                                                       | ``                                                                                               |
| `*_ADDRESS`                       | -                                      | Auto-generated by Helm chart                               | ``                                                       | ``                                                                                               |
