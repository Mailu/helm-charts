# This chart installs the Mailu mail system on kubernetes

## Prerequisites

* a working HTTP/HTTPS ingress controller such as nginx or traefik
* cert-manager installed and configured (including a working cert issuer)
* A node which has a public reachable IP address because mail service binds directly to the node's IP
    * alternatively, inbound traffic routing for mail must be setup externally


## Installation

* create a local values file (see below)
* run `helm install --values my-values-file.yaml incubator/mailu`

## Configuration

| Parameter                         | Description                          | Default                                   |
| --------------------------------- | ------------------------------------ | ----------------------------------------- |
| `mailuVersion`                    | Version/tag of mailu images          | `master`                                  |
| `logLevel`                        | Level of logging                     | `WARNING`                                 |
| `nameOverride`                    | Override the resource name prefix    | `mailu`                                   |
| `fullnameOverride`                | Override the full resource names     | `mailu-{release-name}` (or `mailu` if release-name is `mailu`) |
| `hostnames`                       | List of hostnames to generate certificates and ingresses for | not set           |
| `domain`                          | Mail domain name, see https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames                    | not set                                   |
| `passwordScheme`                  | Scheme used to hash passwords        | `PBKDF2`                                  |
| `secretKey`                       | Session encryption key for admin and webmail | not set                           |
| `mail.messageSizeLimitInMegabytes`| Message size limit in Megabytes      | `50`                                      |
| `mail.authRatelimit`              | Rate limit for authentication requests | `10/minute;1000/hour`                   |
| `initialAccount.username`         | Local part (part after @) for initial admin account | not set                    |
| `initialAccount.domain`           | Domain part (part before @) for initial admin account | not set                  |
| `initialAccount.password`         | Password for initial admin account   | not set                                   |
| `certmanager.issuerType`          | Issuer type for cert manager         | `ClusterIssuer`                           |
| `certmanager.issuerName`          | Name of a preconfigured cert issuer  | `letsencrypt`                             |

... TBD
