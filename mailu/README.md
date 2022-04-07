# This chart installs the Mailu mail system on kubernetes

## Compatibility

| Chart Version                     | Mailu Version  |
| --------------------------------- | -------------- |
| 0.0.x, 0.1.x, 0.2.x               | 1.8            |
| 0.3.x                             | 1.9.x          |

Active development of this chart is only for the latest supported Mailu version (currently 1.9.x).
Branches exists for older mailu versions (e.g. old/mailu-1.8).

## Prerequisites

* ⚠️Starting with version 1.9, you need a validating DNSSEC compatible resolver in order to run Mailu.
* a working HTTP/HTTPS ingress controller such as nginx or traefik
* cert-manager v0.12 or higher installed and configured (including a working cert issuer). Otherwise you will need to handle it by yourself and provide the secret to Mailu.
* A node which has a public reachable IP, static address because mail service binds directly to the node's IP
* A hosting service that allows inbound and outbound traffic on port 25.
* Helm 3 (helm 2 support is dropped with release 0.3.0).

### Warning about open relays

One of the biggest mistakes when running a mail server is a so called "Open Relay". This kind of misconfiguration is in most cases caused by a badly configured
load balancer which hides the originating IP address of an email which makes Mailu think, the email comes from an internal address and ommits authentification and other checks. In the result, your mail server can be abused to spread spam and will get blacklisted within hours.

It is very important that you check your setup for open relay at least:

* after installation
* at any time you change network settings or load balancer configuration

The check is quite simple:
* watch the logs for the "mailu-front" POD
* browse to an open relay checker like https://mxtoolbox.com/diagnostic.aspx
* enter the hostname or IP address of your mail server and start the test

In the logs, you should see some message like

```
2021/10/26 21:23:25 [info] 12#12: *25691 client 18.205.72.90:56741 connected to 0.0.0.0:25
```

It is very important that the IP address shown here is an external public IP address, not an internal like 10.x.x.x, 192.168.x.x or 172.x.x.x.

Also verify that the result of the check confirms that there is no open relay:

```
SMTP Open Relay	OK - Not an open relay.
```


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

* Add the repository via:   
```
helm repo add mailu https://mailu.github.io/helm-charts/
```

* create a local values file:   
```
helm show values mailu/mailu > my-values-file.yaml
```   
Edit the `my-values-file.yaml` to reflect your environment.

* deploy the helm-chart with:   
```
helm install mailu mailu/mailu -n mailu-mailserver --values my-values-file.yaml
```

* Uninstall the helm-chart with:   
```
helm uninstall mailu --namespace=mailu-mailserver
```

Check that the deployed pods are all running.


## Configuration
| Parameter                         | Description                          | Default                                   |
| --------------------------------- | ------------------------------------ | ----------------------------------------- |
| `mailuVersion`                    | Version/tag of mailu images - must be master or a version >=1.9 | `master`       |
| `logLevel`                        | Level of logging                     | `WARNING`                                 |
| `nameOverride`                    | Override the resource name prefix    | `mailu`                                   |
| `clusterDomain`                   | Change the cluster DNS root          | `cluster.local`                           |
| `fullnameOverride`                | Override the full resource names     | `mailu-{release-name}` (or `mailu` if release-name is `mailu`) |
| `hostnames`                       | List of hostnames to generate certificates and ingresses for | not set           |
| `domain`                          | Mail domain name, see https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames | not set |
| `postmaster`                      | Local part of the postmaster address | `postmaster`                              |
| `passwordScheme`                  | Scheme used to hash passwords        | `PBKDF2`                                  |
| `secretKey`                       | Session encryption key for admin and webmail | not set                           |
| `secretKeyRef.name`               | Name of the Secret to fetch the secret key from | not set                        |
| `secretKeyRef.key`                | The name of the key storing the secret key   | not set                           |
| `subnet`                          | Subnet of PODs, used to configure from which IPs internal requests are allowed | `10.42.0.0/16` |
| `mail.messageSizeLimitInMegabytes`| Message size limit in Megabytes      | `50`                                      |
| `mail.authRatelimit`              | Rate limit for authentication requests | `10/minute;1000/hour`                   |
| `initialAccount.username`         | Local part (part before @) for initial admin account | not set                   |
| `initialAccount.domain`           | Domain part (part after @) for initial admin account | not set                   |
| `initialAccount.password`         | Password for initial admin account   | not set                                   |
| `front.controller.kind`           | Use Deployment or DaemonSet for `front` pod(s) | `Deployment`                    |
| `certmanager.enabled`             | Enable the use of CertManager to generate secrets         | `ClusterIssuer`      |
| `certmanager.issuerType`          | Issuer type for cert manager         | `ClusterIssuer`                           |
| `certmanager.issuerName`          | Name of a preconfigured cert issuer  | `letsencrypt`                             |
| `certmanager.apiVersion`          | API-Version for certmanager CRDs     | `cert-manager.io/v1`                      |
| `persistence.size`                | requested PVC size                   | `100Gi`                                   |
| `persistence.storageClass`        | storageClass to use for persistence  | not set                                   |
| `persistence.accessMode`          | accessMode to use for persistence    | `ReadWriteOnce`                           |
| `persistence.annotations`         | Annotations to use in the PVC.       | `{}`                                      |
| `persistence.hostPath`            | path of the hostPath persistence     | not set                                   |
| `persistence.existingClaim`       | existing PVC                         | not set                                   |
| `persistence.claimNameOverride`   | override the generated claim name    | not set                                   |
| `webdav.enabled`                  | enable webdav server                 | `false`                                   |
| `ingress.externalIngress`         | Use externally provided nginx        | `true`                                    |
| `ingress.tlsFlavor`               | Do not change unless you have a custom way of generating the certificates. [Allowed options](https://mailu.io/1.7/compose/setup.html#tls-certificates)  | `cert` (uses certificates provided by cert-manager)                                   |
| `ingress.annotations`             | Annotations for the ingress resource, if enabled. Useful e.g. for configuring the NGINX controller configuration.  | `nginx.ingress.kubernetes.io/proxy-body-size: "0"`                                   |
| `ingress.realIpHeader`            | Header from http(s) ingress that contains the real client IP | `X-Forwarded-For` |
| `ingress.realIpFrom`              | IP/Network from where `realIpHeader` is accepted | `0.0.0.0/0`                   |
| `roundcube.enabled`               | enable roundcube webmail             | `true`                                    |
| `clamav.enabled`                  | enable clamav antivirus              | `true`                                    |
| `dovecot.overrides`               | enable dovecot overrides             | not set                                   |
| `fetchmail.enabled`               | enable fetchmail                     | `false`                                   |
| `fetchmail.delay`                 | delay between fetch attempts         | `600`                                     |
| `database.type`                   | type of database used for mailu      | `sqlite`                                  |
| `database.roundcubeType`          | type of database used for roundcube  | `sqlite`                                  |
| `database.mysql.*`                | mysql specific settings, see below   | not set                                   |
| `timezone`                        | time zone for PODs, see below        | not set                                   |

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

## Timezone

By default, no timezone is set to the PODS, so logs and mail timestamps are all UTC. The option `timezone` allows to use specify a time zone to use (e.g. `Europe/Berlin`).

Note that this requires timezone data installed on the host filesystem that will be mounted into pods as localtime. When https://github.com/Mailu/Mailu/issues/1154 is solved, the chart will be modified to use this solution instead of host files.


## Exposing mail ports to the public

There are several ways to expose mail ports to the public. If you do so, make sure you read and understand the warning above about open relays.

### Running on a single node with a public IP

This is the most straightforward way to run mailu. It can be used when the node where mailu (or at least the "front" POD) runs on a specific node that has a public ip address which is used for mail. All mail ports of the "front" POD will be simply exposed via the "hostPort" function.

To use this mode, set `front.hostPort.enabled` to `true` (which is the default). If your cluster has multiple nodes, you should use `front.nodeSelector` to bind the front container on the node where your public mail IP is located on.

### Running on bare metal with k3s and klipper-lb

If you run on bare metal with k3s (e.g by using k3os), you can use the build-in load balancer [klipper-lb](https://rancher.com/docs/k3s/latest/en/networking/#service-load-balancer). To expose mailu via loadBalancer, set:
* `front.hostPort.enabled`: `false`
* `externalService.enabled`: `true`
* `externalService.type`: `LoadBalancer`
* `externalService.externalTrafficPolicy`: `Local`

The [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip)  is important to preserve the client's source IP and avoid an open relay.

Please perform open relay tests after setup as described above!
