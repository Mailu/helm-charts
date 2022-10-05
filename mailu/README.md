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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admin.affinity | object | `{}` | Affinity for admin pod assignment |
| admin.extraEnvVars | list | `[]` | Extra environment variable to pass to the running container. |
| admin.extraEnvVarsCM | string | `""` | Name of existing ConfigMap containing extra env vars for Mailu admin pod(s) |
| admin.extraEnvVarsSecret | string | `""` | Name of existing Secret containing extra env vars for Mailu admin pod(s) |
| admin.image.pullPolicy | string | `"IfNotPresent"` |  |
| admin.image.repository | string | `"mailu/admin"` |  |
| admin.image.tag | string | `""` | tag defaults to mailuVersion |
| admin.initContainers | list | `[]` | Add additional init containers to the Mailu Admin pod(s) |
| admin.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| admin.livenessProbe.failureThreshold | int | `3` | Failure threshold for livenessProbe |
| admin.livenessProbe.initialDelaySeconds | int | `10` | Initial delay seconds for livenessProbe |
| admin.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| admin.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| admin.livenessProbe.timeoutSeconds | int | `1` | Timeout seconds for livenessProbe |
| admin.nodeSelector | object | `{}` | Node labels for admin pod assignment |
| admin.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| admin.persistence.claimNameOverride | string | `""` |  |
| admin.persistence.size | string | `"20Gi"` |  |
| admin.persistence.storageClass | string | `""` |  |
| admin.podAnnotations | object | `{}` | Admin Pod annotations |
| admin.podLabels | object | `{}` | Admin Pod labels |
| admin.priorityClassName | string | `""` | Mailu admin pods' priorityClassName |
| admin.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| admin.readinessProbe.failureThreshold | int | `3` | Failure threshold for readinessProbe |
| admin.readinessProbe.initialDelaySeconds | int | `10` | Initial delay seconds for readinessProbe |
| admin.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| admin.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| admin.readinessProbe.timeoutSeconds | int | `1` | Timeout seconds for readinessProbe |
| admin.resources.limits.cpu | string | `"500m"` |  |
| admin.resources.limits.memory | string | `"500Mi"` |  |
| admin.resources.requests.cpu | string | `"500m"` |  |
| admin.resources.requests.memory | string | `"500Mi"` |  |
| admin.service.annotations | object | `{}` | Admin service annotations |
| admin.startupProbe.enabled | bool | `false` | Enable startupProbe |
| admin.startupProbe.failureThreshold | int | `3` | Failure threshold for startupProbe |
| admin.startupProbe.initialDelaySeconds | int | `10` | Initial delay seconds for startupProbe |
| admin.startupProbe.periodSeconds | int | `10` | Period seconds for startupProbe |
| admin.startupProbe.successThreshold | int | `1` | Success threshold for startupProbe |
| admin.startupProbe.timeoutSeconds | int | `1` | Timeout seconds for startupProbe |
| admin.tolerations | list | `[]` | admin.tolerations Tolerations for admin pod assignment |
| affinity | object | `{}` | Affinity for pod assignment |
| certmanager.apiVersion | string | `"cert-manager.io/v1"` | Name of the secret to use for certificates |
| certmanager.enabled | bool | `true` | Enable certmanager (create certificates for all domains) |
| certmanager.issuerName | string | `"letsencrypt"` | Name of the issuer to use |
| certmanager.issuerType | string | `"ClusterIssuer"` | Issuer to use for certificates |
| clamav.enabled | bool | `true` |  |
| clamav.image.repository | string | `"mailu/clamav"` |  |
| clamav.livenessProbe.failureThreshold | int | `3` |  |
| clamav.livenessProbe.periodSeconds | int | `10` |  |
| clamav.livenessProbe.timeoutSeconds | int | `5` |  |
| clamav.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| clamav.persistence.claimNameOverride | string | `""` |  |
| clamav.persistence.size | string | `"2Gi"` |  |
| clamav.persistence.storageClass | string | `""` |  |
| clamav.readinessProbe.failureThreshold | int | `1` |  |
| clamav.readinessProbe.periodSeconds | int | `10` |  |
| clamav.readinessProbe.timeoutSeconds | int | `5` |  |
| clamav.resources.limits.cpu | string | `"1000m"` |  |
| clamav.resources.limits.memory | string | `"2Gi"` |  |
| clamav.resources.requests.cpu | string | `"1000m"` |  |
| clamav.resources.requests.memory | string | `"1Gi"` |  |
| clamav.startupProbe.failureThreshold | int | `60` |  |
| clamav.startupProbe.periodSeconds | int | `10` |  |
| clamav.startupProbe.timeoutSeconds | int | `5` |  |
| clusterDomain | string | `"cluster.local"` |  |
| database.mysql | object | `{}` |  |
| database.postgresql | object | `{}` |  |
| database.roundcube.database | string | `"roundcube"` |  |
| database.roundcube.password | string | `"changeme"` |  |
| database.roundcube.type | string | `"sqlite"` |  |
| database.roundcube.username | string | `"roundcube"` |  |
| database.type | string | `"sqlite"` |  |
| domain | string | `""` | Mail domain name. See https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames |
| dovecot.containerSecurityContext | object | `{}` |  |
| dovecot.enabled | bool | `true` |  |
| dovecot.image.repository | string | `"mailu/dovecot"` |  |
| dovecot.livenessProbe.failureThreshold | int | `3` |  |
| dovecot.livenessProbe.periodSeconds | int | `10` |  |
| dovecot.livenessProbe.timeoutSeconds | int | `5` |  |
| dovecot.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| dovecot.persistence.claimNameOverride | string | `""` |  |
| dovecot.persistence.size | string | `"20Gi"` |  |
| dovecot.persistence.storageClass | string | `""` |  |
| dovecot.readinessProbe.failureThreshold | int | `1` |  |
| dovecot.readinessProbe.periodSeconds | int | `10` |  |
| dovecot.readinessProbe.timeoutSeconds | int | `5` |  |
| dovecot.resources.limits.cpu | string | `"500m"` |  |
| dovecot.resources.limits.memory | string | `"500Mi"` |  |
| dovecot.resources.requests.cpu | string | `"500m"` |  |
| dovecot.resources.requests.memory | string | `"500Mi"` |  |
| dovecot.startupProbe.failureThreshold | int | `30` |  |
| dovecot.startupProbe.periodSeconds | int | `10` |  |
| dovecot.startupProbe.timeoutSeconds | int | `5` |  |
| existingSecret | string | `""` | existingSecret Name of the existing secret to retrieve the secretKey. The secret has to contain the secretKey value under the `secret-key` key. |
| external_relay | object | `{}` |  |
| fetchmail.delay | int | `600` |  |
| fetchmail.enabled | bool | `false` | Enable deployment of fetchmail |
| fetchmail.image.repository | string | `"mailu/fetchmail"` |  |
| fetchmail.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| fetchmail.persistence.claimNameOverride | string | `""` |  |
| fetchmail.persistence.size | string | `"20Gi"` |  |
| fetchmail.persistence.storageClass | string | `""` |  |
| fetchmail.resources.limits.cpu | string | `"200m"` |  |
| fetchmail.resources.limits.memory | string | `"200Mi"` |  |
| fetchmail.resources.requests.cpu | string | `"100m"` |  |
| fetchmail.resources.requests.memory | string | `"100Mi"` |  |
| front.controller.kind | string | `"Deployment"` | Deployment or DaemonSet |
| front.externalService.annotations | object | `{}` |  |
| front.externalService.enabled | bool | `false` |  |
| front.externalService.externalTrafficPolicy | string | `"Local"` |  |
| front.externalService.imap | bool | `false` |  |
| front.externalService.imaps | bool | `true` |  |
| front.externalService.pop3 | bool | `false` |  |
| front.externalService.pop3s | bool | `true` |  |
| front.externalService.smtp | bool | `true` |  |
| front.externalService.smtps | bool | `true` |  |
| front.externalService.submission | bool | `true` |  |
| front.externalService.type | string | `"ClusterIP"` |  |
| front.hostPort | object | `{"enabled":true}` | Expose front mail ports via hostPort |
| front.image.repository | string | `"mailu/nginx"` |  |
| front.image.tag | string | defaults to mailuVersion | Fron pod image tag |
| front.livenessProbe.failureThreshold | int | `3` |  |
| front.livenessProbe.periodSeconds | int | `10` |  |
| front.livenessProbe.timeoutSeconds | int | `5` |  |
| front.nodeSelector | object | `{}` |  |
| front.readinessProbe.failureThreshold | int | `1` |  |
| front.readinessProbe.periodSeconds | int | `10` |  |
| front.readinessProbe.timeoutSeconds | int | `5` |  |
| front.resources.limits.cpu | string | `"200m"` |  |
| front.resources.limits.memory | string | `"200Mi"` |  |
| front.resources.requests.cpu | string | `"100m"` |  |
| front.resources.requests.memory | string | `"100Mi"` |  |
| front.startupProbe.failureThreshold | int | `30` |  |
| front.startupProbe.periodSeconds | int | `10` |  |
| front.startupProbe.timeoutSeconds | int | `5` |  |
| fullnameOverride | string | `""` |  |
| hostnames | list | `[]` | List of hostnames to generate certificates and ingresses for. The first will be used as primary mail hostname |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"0"` |  |
| ingress.className | string | `""` |  |
| ingress.externalIngress | bool | `true` |  |
| ingress.realIpFrom | string | `"0.0.0.0/0"` |  |
| ingress.realIpHeader | string | `"X-Forwarded-For"` |  |
| ingress.tlsFlavor | string | `"cert"` |  |
| initialAccount | object | `{}` | An initial account can automatically be created: |
| logLevel | string | `"WARNING"` | default log level. can be overridden globally or per service |
| mail.authRatelimitExemtionLength | int | `86400` |  |
| mail.authRatelimitIP | string | `"60/hour"` | Configuration to prevent brute-force attacks. See the documentation for further information: https://mailu.io/master/configuration.html |
| mail.authRatelimitIPv4Mask | int | `24` |  |
| mail.authRatelimitIPv6Mask | int | `56` |  |
| mail.authRatelimitUser | string | `"100/day"` |  |
| mail.messageRatelimit | string | `"200/day"` | Configuration to reduce outgoing spam in case of an compromised account. See the documentation for further information: https://mailu.io/1.9/configuration.html?highlight=MESSAGE_RATELIMIT |
| mail.messageSizeLimitInMegabytes | int | `50` |  |
| mailuVersion | string | `"1.9.26"` | Version/tag of mailu images - must be master or a version >= 1.9 |
| mariadb.architecture | string | `"standalone"` |  |
| mariadb.auth.database | string | `"mailu"` |  |
| mariadb.auth.existingSecret | string | `""` |  |
| mariadb.auth.password | string | `"changeme"` |  |
| mariadb.auth.rootPassword | string | `"changeme"` |  |
| mariadb.auth.username | string | `"mailu"` |  |
| mariadb.enabled | bool | `false` |  |
| mariadb.primary.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| mariadb.primary.persistence.enabled | bool | `false` |  |
| mariadb.primary.persistence.size | string | `"8Gi"` |  |
| mysql.image.repository | string | `"library/mariadb"` |  |
| mysql.image.tag | string | `"10.4.10"` |  |
| mysql.livenessProbe.failureThreshold | int | `3` |  |
| mysql.livenessProbe.periodSeconds | int | `10` |  |
| mysql.livenessProbe.timeoutSeconds | int | `5` |  |
| mysql.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| mysql.persistence.claimNameOverride | string | `""` |  |
| mysql.persistence.size | string | `"20Gi"` |  |
| mysql.persistence.storageClass | string | `""` |  |
| mysql.readinessProbe.failureThreshold | int | `1` |  |
| mysql.readinessProbe.periodSeconds | int | `10` |  |
| mysql.readinessProbe.timeoutSeconds | int | `5` |  |
| mysql.resources.limits.cpu | string | `"200m"` |  |
| mysql.resources.limits.memory | string | `"512Mi"` |  |
| mysql.resources.requests.cpu | string | `"100m"` |  |
| mysql.resources.requests.memory | string | `"256Mi"` |  |
| mysql.startupProbe.failureThreshold | int | `30` |  |
| mysql.startupProbe.periodSeconds | int | `10` |  |
| mysql.startupProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.single_pvc | bool | `true` | Setings for a single volume for all apps. Set single_pvc: false to use a per app volume and set the properties in <app>.persistence (ex. admin.persistence) |
| persistence.size | string | `"100Gi"` |  |
| postfix.containerSecurityContext | object | `{}` |  |
| postfix.image.repository | string | `"mailu/postfix"` |  |
| postfix.livenessProbe.failureThreshold | int | `3` |  |
| postfix.livenessProbe.periodSeconds | int | `10` |  |
| postfix.livenessProbe.timeoutSeconds | int | `5` |  |
| postfix.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| postfix.persistence.claimNameOverride | string | `""` |  |
| postfix.persistence.size | string | `"20Gi"` |  |
| postfix.persistence.storageClass | string | `""` |  |
| postfix.readinessProbe.failureThreshold | int | `1` |  |
| postfix.readinessProbe.periodSeconds | int | `10` |  |
| postfix.readinessProbe.timeoutSeconds | int | `5` |  |
| postfix.resources.limits.cpu | string | `"500m"` |  |
| postfix.resources.limits.memory | string | `"2Gi"` |  |
| postfix.resources.requests.cpu | string | `"500m"` |  |
| postfix.resources.requests.memory | string | `"2Gi"` |  |
| postfix.startupProbe.failureThreshold | int | `30` |  |
| postfix.startupProbe.periodSeconds | int | `10` |  |
| postfix.startupProbe.timeoutSeconds | int | `5` |  |
| postgresql.architecture | string | `"standalone"` |  |
| postgresql.auth.database | string | `"mailu"` |  |
| postgresql.auth.enablePostgresUser | bool | `true` |  |
| postgresql.auth.existingSecret | string | `""` |  |
| postgresql.auth.password | string | `"changeme"` |  |
| postgresql.auth.postgresPassword | string | `"changeme"` |  |
| postgresql.auth.secretKeys.adminPasswordKey | string | `"postgres-password"` |  |
| postgresql.auth.secretKeys.replicationPasswordKey | string | `"replication-password"` |  |
| postgresql.auth.secretKeys.userPasswordKey | string | `"password"` |  |
| postgresql.auth.username | string | `"mailu"` |  |
| postgresql.enabled | bool | `false` |  |
| postgresql.primary.persistence.enabled | bool | `false` |  |
| postmaster | string | `"postmaster"` | local part of the postmaster email address (Mailu will use @$DOMAIN as domain part) |
| redis.image.repository | string | `"redis"` |  |
| redis.image.tag | string | `"5-alpine"` |  |
| redis.livenessProbe.failureThreshold | int | `3` |  |
| redis.livenessProbe.periodSeconds | int | `10` |  |
| redis.livenessProbe.timeoutSeconds | int | `5` |  |
| redis.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| redis.persistence.claimNameOverride | string | `""` |  |
| redis.persistence.size | string | `"20Gi"` |  |
| redis.persistence.storageClass | string | `""` |  |
| redis.readinessProbe.failureThreshold | int | `1` |  |
| redis.readinessProbe.periodSeconds | int | `10` |  |
| redis.readinessProbe.timeoutSeconds | int | `5` |  |
| redis.resources.limits.cpu | string | `"200m"` |  |
| redis.resources.limits.memory | string | `"300Mi"` |  |
| redis.resources.requests.cpu | string | `"100m"` |  |
| redis.resources.requests.memory | string | `"200Mi"` |  |
| redis.startupProbe.failureThreshold | int | `30` |  |
| redis.startupProbe.periodSeconds | int | `10` |  |
| redis.startupProbe.timeoutSeconds | int | `5` |  |
| roundcube.enabled | bool | `true` | Enable deployment of Roundcube webmail |
| roundcube.image.repository | string | `"mailu/roundcube"` |  |
| roundcube.livenessProbe.failureThreshold | int | `3` |  |
| roundcube.livenessProbe.periodSeconds | int | `10` |  |
| roundcube.livenessProbe.timeoutSeconds | int | `5` |  |
| roundcube.logLevel | string | `""` | Set the log level for Roundcube |
| roundcube.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| roundcube.persistence.claimNameOverride | string | `""` |  |
| roundcube.persistence.size | string | `"20Gi"` |  |
| roundcube.persistence.storageClass | string | `""` |  |
| roundcube.readinessProbe.failureThreshold | int | `1` |  |
| roundcube.readinessProbe.periodSeconds | int | `10` |  |
| roundcube.readinessProbe.timeoutSeconds | int | `5` |  |
| roundcube.resources.limits.cpu | string | `"200m"` |  |
| roundcube.resources.limits.memory | string | `"200Mi"` |  |
| roundcube.resources.requests.cpu | string | `"100m"` |  |
| roundcube.resources.requests.memory | string | `"100Mi"` |  |
| roundcube.startupProbe.failureThreshold | int | `30` |  |
| roundcube.startupProbe.periodSeconds | int | `10` |  |
| roundcube.startupProbe.timeoutSeconds | int | `5` |  |
| roundcube.uri | string | `"/roundcube"` |  |
| rspamd.image.repository | string | `"mailu/rspamd"` |  |
| rspamd.livenessProbe.failureThreshold | int | `3` |  |
| rspamd.livenessProbe.periodSeconds | int | `10` |  |
| rspamd.livenessProbe.timeoutSeconds | int | `5` |  |
| rspamd.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| rspamd.persistence.claimNameOverride | string | `""` |  |
| rspamd.persistence.size | string | `"1Gi"` |  |
| rspamd.persistence.storageClass | string | `""` |  |
| rspamd.readinessProbe.failureThreshold | int | `1` |  |
| rspamd.readinessProbe.periodSeconds | int | `10` |  |
| rspamd.readinessProbe.timeoutSeconds | int | `5` |  |
| rspamd.resources.limits.cpu | string | `"200m"` |  |
| rspamd.resources.limits.memory | string | `"200Mi"` |  |
| rspamd.resources.requests.cpu | string | `"100m"` |  |
| rspamd.resources.requests.memory | string | `"100Mi"` |  |
| rspamd.startupProbe.failureThreshold | int | `90` |  |
| rspamd.startupProbe.periodSeconds | int | `10` |  |
| rspamd.startupProbe.timeoutSeconds | int | `5` |  |
| rspamd_clamav_persistence.accessMode | string | `"ReadWriteOnce"` |  |
| rspamd_clamav_persistence.claimNameOverride | string | `""` |  |
| rspamd_clamav_persistence.single_pvc | bool | `false` |  |
| rspamd_clamav_persistence.size | string | `"20Gi"` |  |
| rspamd_clamav_persistence.storageClass | string | `""` |  |
| secretKey | string | `""` | The secret key is required for protecting authentication cookies and must be set individually for each deployment If empty, a random secret key will be generated and saved in a secret |
| subnet | string | `"10.42.0.0/16"` | Change this if you're using different address ranges for pods |
| tolerations | object | `{}` | Tolerations for pod assignment |
| webdav.enabled | bool | `false` | Enable deployment of WebDAV server (using Radicale) |
| webdav.image.repository | string | `"mailu/radicale"` |  |
| webdav.livenessProbe.failureThreshold | int | `3` |  |
| webdav.livenessProbe.periodSeconds | int | `10` |  |
| webdav.livenessProbe.timeoutSeconds | int | `5` |  |
| webdav.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| webdav.persistence.claimNameOverride | string | `""` |  |
| webdav.persistence.size | string | `"20Gi"` |  |
| webdav.persistence.storageClass | string | `""` |  |
| webdav.readinessProbe.failureThreshold | int | `1` |  |
| webdav.readinessProbe.periodSeconds | int | `10` |  |
| webdav.readinessProbe.timeoutSeconds | int | `5` |  |
| webdav.startupProbe.failureThreshold | int | `30` |  |
| webdav.startupProbe.periodSeconds | int | `10` |  |
| webdav.startupProbe.timeoutSeconds | int | `5` |  |

### Example values.yaml to get started

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
