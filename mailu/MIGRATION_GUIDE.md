# Migration guide

Version `1.0.0` is a major release of Mailu Helm Chart. It is not compatible with previous versions.
This guide will help you migrate your data from a previous version to `1.0.0`.

**We strongly recommend to backup your data before migrating. We will not be responsible in case of any loss of data.**

## Migration steps

1. Backup your data
2. Create a new `values.yaml` file (we recommend to create a new one from scratch)
3. Uninstall the previous version of the chart
4. Install the new version of the chart
5. Restore your data

In-place upgrade could be possible but is not supported.
If you want to perform an in-place upgrade and you are using the built-in MySQL database, you will need to migrate your data manually and backup your existing data **before** attempting the upgrade.
You will also need to manually delete the existing `Ingress`, as well as all existing `Deployment` resources.

**Running the upgrade will remove the existing MySQL deployment and data!**

## Breaking changes

- The embedded MySQL database has been removed from this chart.
  This chart can now deploy MariaDB or Postgresql database using the Bitnami charts.
  An external database can also be configured.
- The embedded Redis installation has been removed from this chart.
  This chart will now deploy Redis using the Bitnami charts.
- Several configuration keys have been renamed, please see more in the [Values mapping](#values-mapping) section.

## Values mapping

| Old configuration key                   | New configuration key                       | Comments                                                                                                            |
| --------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `database.type`                         | `-`                                         | Removed. Use `postgresql.enabled` or `mariadb.enabled` instead.                                                     |
| `database.roundcubeType`                | `-`                                         | Removed. Use `postgresql.enabled` or `mariadb.enabled` instead.                                                     |
| `database.mysql.roundcubeDatabase`      | `global.database.roundcube.database`        |                                                                                                                     |
| `database.mysql.roundcubePassword`      | `global.database.roundcube.password`        | Ignored if using `global.database.roundcube.existingSecret`                                                         |
| `database.mysql.roundcubeUser`          | `global.database.roundcube.username`        |                                                                                                                     |
| `database.mysql.rootPassword`           | `mariadb.auth.rootPassword`                 | Check [Bitnami MariaDB](https://artifacthub.io/packages/helm/bitnami/mariadb) for more configuration options.       |
| `database.mysql.database`               | `mariadb.auth.database`                     | Check [Bitnami MariaDB](https://artifacthub.io/packages/helm/bitnami/mariadb) for more configuration options.       |
| `database.mysql.user`                   | `mariadb.auth.username`                     | Check [Bitnami MariaDB](https://artifacthub.io/packages/helm/bitnami/mariadb) for more configuration options.       |
| `database.mysql.password`               | `mariadb.auth.password`                     | Check [Bitnami MariaDB](https://artifacthub.io/packages/helm/bitnami/mariadb) for more configuration options.       |
| `database.postgresql.roundcubeDatabase` | `global.database.roundcube.database`        |                                                                                                                     |
| `database.postgresql.roundcubePassword` | `global.database.roundcube.password`        | Ignored if using `global.database.roundcube.existingSecret`                                                         |
| `database.postgresql.roundcubeUser`     | `global.database.roundcube.username`        |                                                                                                                     |
| `-`                                     | `postgresql.auth.postgresPassword`          | Check [Bitnami Postgresql](https://artifacthub.io/packages/helm/bitnami/postgresql) for more configuration options. |
| `database.postgresql.database`          | `postgresql.auth.database`                  | Check [Bitnami Postgresql](https://artifacthub.io/packages/helm/bitnami/postgresql) for more configuration options. |
| `database.postgresql.user`              | `postgresql.auth.username`                  | Check [Bitnami Postgresql](https://artifacthub.io/packages/helm/bitnami/postgresql) for more configuration options. |
| `database.postgresql.password`          | `postgresql.auth.password`                  | Check [Bitnami Postgresql](https://artifacthub.io/packages/helm/bitnami/postgresql) for more configuration options. |
| `mail.messageSizeLimitInMegabytes`      | `limits.messageSizeLimitInMegabytes`        |                                                                                                                     |
| `mail.authRatelimit`                    | `limits.authRatelimit.ip`                   | Additional limits available, please see `values.yaml` file for more options.                                        |
| `front.externalService.pop3.pop3`       | `front.externalService.services.pop3`       |                                                                                                                     |
| `front.externalService.pop3.pop3s`      | `front.externalService.services.pop3s`      |                                                                                                                     |
| `front.externalService.imap.imap`       | `front.externalService.services.imap`       |                                                                                                                     |
| `front.externalService.imap.imaps`      | `front.externalService.services.imaps`      |                                                                                                                     |
| `front.externalService.smtp.smtp`       | `front.externalService.services.smtp`       |                                                                                                                     |
| `front.externalService.smtp.smtps`      | `front.externalService.services.smtps`      |                                                                                                                     |
| `front.externalService.smtp.submission` | `front.externalService.services.submission` |                                                                                                                     |
| `front.controller.kind`                 | `-`                                         | Removed for now, using `Deployment` kind. To be addressed at a later stage.                                         |
| `certmanager.*`                         | `-`                                         | Removed. Configure using annotations on `ingress.annotations` to generate a valid certificate instead.              |
| `ingress.tlsFlavor`                     | `ingress.tlsFlavorOverride`                 |                                                                                                                     |
| `ingress.externalIngress`               | `ingress.enabled`                           |                                                                                                                     |
| `roundcube.*`                           | `webmail.*`                                 | `roundcube` has been renamed to `webmail`                                                                           |
