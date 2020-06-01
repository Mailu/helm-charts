# This chart installs the Mailu mail system on kubernetes

## Prerequisites

* a working HTTP/HTTPS ingress controller such as nginx or traefik
* cert-manager v0.12 or higher installed and configured (including a working cert issuer).  
* A node which has a public reachable IP address because mail service binds directly to the node's IP
    * alternatively, inbound traffic routing for mail must be setup externally


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
| `configmap.enabled`               | employ a single configmap instead of environment variables on each container | `false`                                    |

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

By default both, mailu and dovecot uses an embedded sqlite database. The chart allows to use an embedded or external mysql database instead. It can be controlled by the following values:

### Using mysql for mailu

Set ``database.type`` to ``mysql``. ``database.mysql.database``, ``database.mysql.user``, and ``database.mysql.password`` must also be set.

### Using mysql for roundcube

Set ``database.roundcubeType`` to ``mysql``. ``database.mysql.roundcubeDatabase``, ``database.mysql.roundcubeUser``, and ``database.mysql.roundcubePassword`` must also be set.

### Using the internal mysql database

The chart deploys an instance of mariadb if either ``database.type`` or ``database.roundcubeType`` is set to ``mysql``. If both are set, they use the same mariadb instance. A database root password can be set with ``database.mysql.rootPassword``. If not set, a random root password will be used.

### Using an external mysql database

An external mysql database can be used by setting ``database.mysql.host``. The chart does not support different mysql hosts for mailu and dovecot. Using other mysql ports than the default 3306 port is also nur supported by the chart.
