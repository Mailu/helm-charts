# This chart installs the Mailu mail system on kubernetes

## Prerequisites

* a working HTTP/HTTPS ingress controller such as nginx or traefik
* cert-manager v0.12 or higher installed and configured (including a working cert issuer).  
* A node which has a public reachable IP, static address because mail service binds directly to the node's IP
* A hosting service that allows inbound and outbound traffic on port 25.

### Warning, this will not work on most cloud providers

* Google cloud does not allow outgoing connections to connect to port 25. You will not be able to send
  mails with mailu on google cloud (https://googlecloudplatform.uservoice.com/forums/302595-compute-engine/suggestions/12422808-please-unblock-port-25-allow-outbound-mail-connec)
* Many cloud providers don't allow to assign fixed IPs directly to nodes. They use proxies or load balancers instead. While
  this works well with HTTP/HTTPs, on raw TCP connections (such as mail protocol connections) the originating IP get's lost.
  There's a so called "proxy protocol" as a solution for this limitation but that's not yet supported by mailu (due the lack of
  support in the nginx mail modules). Without the original IP information, a mail server will not work properly, or worse, will be
  an open relay.
* If you'd like to run mailu on kubernetes, consider to rent a cheap VPS and run kuberneres on it (e.g. using rancher2). A good option is to
  use hetzner cloud VPS (author's personal opinion).
* Please don't open issues in the bug tracker if your mail server is not working because your cloud provider blocks port 25 or hides
  source ip addresses behind a load balancer.

## Installation

* Add the repository via `helm repo add mailu https://mailu.github.io/helm-charts/`
* create a local values file (see below)
* run `helm install --values my-values-file.yaml mailu/mailu`

## Configuration
| Parameter                         | Description                          | Default                                   |
| --------------------------------- | ------------------------------------ | ----------------------------------------- |
| `mailuVersion`                    | Version/tag of mailu images - must be master or a version >=1.8 | `master`                                  |
| `logLevel`                        | Level of logging                     | `WARNING`                                 |
| `nameOverride`                    | Override the resource name prefix    | `mailu`                                   |
| `clusterDomain`                   | Change the cluster DNS root          | `cluster.local`                           |
| `fullnameOverride`                | Override the full resource names     | `mailu-{release-name}` (or `mailu` if release-name is `mailu`) |
| `hostnames`                       | List of hostnames to generate certificates and ingresses for | not set           |
| `domain`                          | Mail domain name, see https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames | not set |
| `passwordScheme`                  | Scheme used to hash passwords        | `PBKDF2`                                  |
| `secretKey`                       | Session encryption key for admin and webmail | not set                           |
| `subnet`                          | Subnet of PODs, used to configure from which IPs internal requests are allowed | `10.42.0.0/16` |
| `mail.messageSizeLimitInMegabytes`| Message size limit in Megabytes      | `50`                                      |
| `mail.authRatelimit`              | Rate limit for authentication requests | `10/minute;1000/hour`                   |
| `initialAccount.username`         | Local part (part before @) for initial admin account | not set                   |
| `initialAccount.domain`           | Domain part (part after @) for initial admin account | not set                   |
| `initialAccount.password`         | Password for initial admin account   | not set                                   |
| `certmanager.issuerType`          | Issuer type for cert manager         | `ClusterIssuer`                           |
| `certmanager.issuerName`          | Name of a preconfigured cert issuer  | `letsencrypt`                             |
| `persistence.size`                | requested PVC size                   | `100Gi`                                   |
| `persistence.storageClass`        | storageClass to use for persistence  | not set                                   |
| `persistence.accessMode`          | accessMode to use for persistence    | `ReadWriteOnce`                           |
| `persistence.annotations`          | Annotations to use in the PVC.    | `{}`                           |
| `persistence.hostPath`            | path of the hostPath persistence     | not set                                   |
| `persistence.existingClaim`       | existing PVC                         | not set                                   |
| `persistence.claimNameOverride`   | override the generated claim name    | not set                                   |
| `webdav.enabled`                  | enable webdav server                 | `false`                                   |
| `ingress.externalIngress`         | Use externally provided nginx        | `true`                                    |
| `ingress.tlsFlavor`               | Do not change unless you have a custom way of generating the certificates. [Allowed options](https://mailu.io/1.7/compose/setup.html#tls-certificates)  | `cert` (uses certificates provided by cert-manager)                                   |
| `ingress.annotations`               | Annotations for the ingress resource, if enabled. Useful e.g. for configuring the NGINX controller configuration.  | `nginx.ingress.kubernetes.io/proxy-body-size: "0"`                                   |
| `roundcube.enabled`               | enable roundcube webmail             | `true`                                    |
| `clamav.enabled`                  | enable clamav antivirus              | `true`                                    |
| `database.type`                   | type of database used for mailu      | `sqlite`                                  |
| `database.roundcubeType`          | type of database used for roundcube  | `sqlite`                                  |
| `database.mysql.*`                | mysql specific settings, see below   | not set                                   |

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

## Ingress

The default ingress is handled externally. In some situations, this is problematic, such as when webmail should be accessible
 on the same address as the exposed ports. Kubernetes services cannot provide such capabilities without vendor-specific annotations.
 
By setting `ingress.externalIngress` to false, the internal NGINX instance provided by `front` will configure TLS according to
 `ingress.tlsFlavor` and redirect `http` scheme connections to `https`. 
 
 CAUTION: This configuration exposes `/admin` to all clients with access to the web UI.

## Database

By default both, Mailu and RoundCube uses an embedded SQLite database. 

The chart allows to use an embedded MySQL or external MySQL or PostgreSQL databases instead. It can be controlled by the following values:

### MySQL / MariaDB

In the sub-sections, we we use the reference "MySQL", it is meant for any MySQL-compatible database system (like MariaDB). 

#### Using MySQL for Mailu

Set ``database.type`` to ``mysql``.
 
The ``database.mysql.database``, ``database.mysql.user``, and ``database.mysql.password`` variables must also be set.

### Using MySQL for RoundCube

Set ``database.roundcubeType`` to ``mysql``.
 
The ``database.mysql.roundcubeDatabase``, ``database.mysql.roundcubeUser``, and ``database.mysql.roundcubePassword`` variables must also be set.

### Using the internal MySQL database

The chart deploys an instance of MariaDB if either ``database.type`` or ``database.roundcubeType`` is set to ``mysql`` and the ``database.mysql.host`` is NOT set.

Mailu and RoundCube will use the same MariaDB instance. A database root password can be set with ``database.mysql.rootPassword``. If not set, a random root password will be used.

### Using an external mysql database

An external mysql database can be used by setting ``database.mysql.host``. The chart does not support different mysql hosts for mailu and dovecot. Using other mysql ports than the default 3306 port is also nur supported by the chart.

### PostgreSQL

PostgreSQL can be used as an external database management system for Mailu and Roundcube.

An external PostgreSQL database can be used by setting ``database.postgresql.host``.

The chart does not support different PostgreSQL hosts for Mailu and RoundCube. Using other PostgreSQL ports than the default 5432 port is also not supported by the chart.

#### Using PostgreSQL for Mailu

Set ``database.type`` to ``postgresql``.
 
The ``database.postgresql.database``, ``database.postgresql.user``, and ``database.postgresql.password`` chart values must also be set.

#### Using Postgresql for Roundcube

Set ``database.roundcubeType`` to ``postgresql``.
 
The``database.postgresql.roundcubeDatabase``, ``database.postgresql.roundcubeUser``, and ``database.postgresql.roundcubePassword`` must also be set.
