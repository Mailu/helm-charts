# Changelog

## [2.6.3](https://github.com/Mailu/helm-charts/compare/mailu-2.6.2...mailu-2.6.3) (2025-12-16)


### Bug Fixes

* **github-release:** update release mailu/mailu ( 2024.06.45 ➔ 2024.06.46 ) ([#534](https://github.com/Mailu/helm-charts/issues/534)) ([353a7c7](https://github.com/Mailu/helm-charts/commit/353a7c72ebba6a76ae145924259e51638af32db3))

## [2.6.2](https://github.com/Mailu/helm-charts/compare/mailu-2.6.1...mailu-2.6.2) (2025-12-05)


### Bug Fixes

* clamav volumeClaimTemplates use matchLabels ([#522](https://github.com/Mailu/helm-charts/issues/522)) ([fa88206](https://github.com/Mailu/helm-charts/commit/fa88206e531d7e5e4e937f26809a0ccf1480bae2))

## [2.6.1](https://github.com/Mailu/helm-charts/compare/mailu-2.6.0...mailu-2.6.1) (2025-11-06)


### Bug Fixes

* ensure PORTS value is quoted ([#515](https://github.com/Mailu/helm-charts/issues/515)) ([2d3ce2d](https://github.com/Mailu/helm-charts/commit/2d3ce2d82455bcaaa57dc81c2259a21ec2869a42))

## [2.6.0](https://github.com/Mailu/helm-charts/compare/mailu-2.5.1...mailu-2.6.0) (2025-11-05)


### Features

* support mta-sts configuration with overrides ([#396](https://github.com/Mailu/helm-charts/issues/396)) ([051c3b2](https://github.com/Mailu/helm-charts/commit/051c3b21208658915469e276cf6941a147b3a59d))


### Bug Fixes

* Allow set externalIPs ([#499](https://github.com/Mailu/helm-charts/issues/499)) ([b30a1a3](https://github.com/Mailu/helm-charts/commit/b30a1a32c43aea7618c471fe3154e28e13026dcd))
* prevent overzealous whitespace removal ([#509](https://github.com/Mailu/helm-charts/issues/509)) ([5a65b6b](https://github.com/Mailu/helm-charts/commit/5a65b6b2609d3beb3625fd2556f94fc5429ffede)), closes [#508](https://github.com/Mailu/helm-charts/issues/508)
* type of db ExtraEnvVars values ([#466](https://github.com/Mailu/helm-charts/issues/466)) ([64a068d](https://github.com/Mailu/helm-charts/commit/64a068d5171d69d02d4587fd948cd4d2abca0af9))

## [2.5.1](https://github.com/Mailu/helm-charts/compare/mailu-2.5.0...mailu-2.5.1) (2025-10-22)


### Bug Fixes

* **docs:** readme OCD ([#381](https://github.com/Mailu/helm-charts/issues/381)) ([6147f84](https://github.com/Mailu/helm-charts/commit/6147f8495ceef6bfa789b4e11cb2dbbdb74f8276))
* **github-release:** update release mailu/mailu ( 2024.06.44 ➔ 2024.06.45 ) ([#504](https://github.com/Mailu/helm-charts/issues/504)) ([40479b4](https://github.com/Mailu/helm-charts/commit/40479b4e8af7a47b8cda74cff1d8220fca66abe6))

## [2.5.0](https://github.com/Mailu/helm-charts/compare/mailu-2.4.0...mailu-2.5.0) (2025-10-17)


### Features

* **externalService:** allow to set labels ([#470](https://github.com/Mailu/helm-charts/issues/470)) ([e906264](https://github.com/Mailu/helm-charts/commit/e906264e6765d3ad1ea8daf9cfa9e9149518ba9c)), closes [#275](https://github.com/Mailu/helm-charts/issues/275)


### Bug Fixes

* **container:** update image docker.io/apache/tika ( 3.2.2.0 ➔ 3.2.3.0 ) ([#465](https://github.com/Mailu/helm-charts/issues/465)) ([995b7eb](https://github.com/Mailu/helm-charts/commit/995b7eb67985d2e1004c39fed0adf7d61d0c6b4a))
* Don't set empty vars instead of setting them to empty strings ([#475](https://github.com/Mailu/helm-charts/issues/475)) ([9ddb8b8](https://github.com/Mailu/helm-charts/commit/9ddb8b82d2493ceaced510f3e37b7d5e5765ed37))
* **gh-actions lint-and-test:** correct indentation ([#492](https://github.com/Mailu/helm-charts/issues/492)) ([a03411d](https://github.com/Mailu/helm-charts/commit/a03411d19b6ebfb466187178b0aa90dd7f6d20fc)), closes [#490](https://github.com/Mailu/helm-charts/issues/490)
* **github-release:** update release mailu/mailu ( 2024.06.43 ➔ 2024.06.44 ) ([ab06eb6](https://github.com/Mailu/helm-charts/commit/ab06eb643829c869d8aea9756aefccf732129924))
* **serviceMonitor:** labelSelector declaration ([#472](https://github.com/Mailu/helm-charts/issues/472)) ([3b03faa](https://github.com/Mailu/helm-charts/commit/3b03faa3c3df7e9ff5915bd8d30a42d1d1491562)), closes [#471](https://github.com/Mailu/helm-charts/issues/471)

## [2.4.0](https://github.com/Mailu/helm-charts/compare/mailu-2.3.1...mailu-2.4.0) (2025-09-05)


### Features

* add metrics monitoring for rspamd and dovecot ([#461](https://github.com/Mailu/helm-charts/issues/461)) ([cf3c2fa](https://github.com/Mailu/helm-charts/commit/cf3c2fad5f0ad9a9a4669e321cc9718cf2dc9cc7))

## [2.3.1](https://github.com/Mailu/helm-charts/compare/mailu-2.3.0...mailu-2.3.1) (2025-08-31)


### Bug Fixes

* remove deprecated common template (fixes [#449](https://github.com/Mailu/helm-charts/issues/449)) ([#451](https://github.com/Mailu/helm-charts/issues/451)) ([b262be4](https://github.com/Mailu/helm-charts/commit/b262be4a7f827fa3aee855f39ffb327548f276f1))

## [2.3.0](https://github.com/Mailu/helm-charts/compare/mailu-2.2.2...mailu-2.3.0) (2025-08-28)


### Features

* bump mailu version to 2024.06.41 ([#431](https://github.com/Mailu/helm-charts/issues/431)) ([ad72d37](https://github.com/Mailu/helm-charts/commit/ad72d3779f2601cc1c52b02b04130fbe3b6cc78a))


### Bug Fixes

* bump mailu version to 2024.06.43 ([#436](https://github.com/Mailu/helm-charts/issues/436)) ([a04015a](https://github.com/Mailu/helm-charts/commit/a04015a870bcd44bf6de018af9fcff0ac7f908d1))
* pin tika image to 3.2.2.0-full ([#435](https://github.com/Mailu/helm-charts/issues/435)) ([921e66b](https://github.com/Mailu/helm-charts/commit/921e66b8e7e3a2dd28d4781950d5069fe27a9745))
* remove env vars from clamav, oletools and tika pods ([#428](https://github.com/Mailu/helm-charts/issues/428)) ([ea26d85](https://github.com/Mailu/helm-charts/commit/ea26d85d400f223dddd63a6e322f4e27984b07de))
* restrict tika and oletools internet access ([#432](https://github.com/Mailu/helm-charts/issues/432)) ([c112e9a](https://github.com/Mailu/helm-charts/commit/c112e9aab486b0c36e0aa181d1bd36f4f10d3e51))
* update bitnami dependencies and use bitnamilegacy repo ([#434](https://github.com/Mailu/helm-charts/issues/434)) ([e5f55f2](https://github.com/Mailu/helm-charts/commit/e5f55f2c2941a4b10aa90f4af36131ea256b7a53))
* update tika (CVE-2025-54988) ([#430](https://github.com/Mailu/helm-charts/issues/430)) ([270a2d0](https://github.com/Mailu/helm-charts/commit/270a2d09c477a06fcdb7e1760f3eb6913e889fc6))

## [2.2.2](https://github.com/Mailu/helm-charts/compare/mailu-2.2.1...mailu-2.2.2) (2025-05-25)


### Bug Fixes

* fix proxy protocol check ([#414](https://github.com/Mailu/helm-charts/issues/414)) ([5304600](https://github.com/Mailu/helm-charts/commit/5304600aac1d55b4c2ac19123d7793909e7d84e0))

## [2.2.1](https://github.com/Mailu/helm-charts/compare/mailu-2.2.0...mailu-2.2.1) (2025-05-25)


### Miscellaneous Chores

* trigger release ([41e7f53](https://github.com/Mailu/helm-charts/commit/41e7f53869be97ebf1f99785f3728965d5bee4d8))

## [2.2.0](https://github.com/Mailu/helm-charts/compare/mailu-2.1.2...mailu-2.2.0) (2025-05-25)


### Features

* ✨ move chart to subdir charts ([#389](https://github.com/Mailu/helm-charts/issues/389)) ([f76c60a](https://github.com/Mailu/helm-charts/commit/f76c60a540a5693fbadd51e3ce21d47e83106abb))


### Bug Fixes

* added PROXY_PROTOCOL environment variable ([#375](https://github.com/Mailu/helm-charts/issues/375)) ([a80d638](https://github.com/Mailu/helm-charts/commit/a80d6384331928444810be37918fc5533220330e))
* Fix Chart readme typos ([#400](https://github.com/Mailu/helm-charts/issues/400)) ([f13b97e](https://github.com/Mailu/helm-charts/commit/f13b97e1c65449ff9ef16a42bb68778a89ad30b8))
* fix clamav probes ([#408](https://github.com/Mailu/helm-charts/issues/408)) ([4492c43](https://github.com/Mailu/helm-charts/commit/4492c43b7f676f32def41868581cb3c010f26795))
* update mailu to 2024.06.36 and clamav to 1.4 ([#409](https://github.com/Mailu/helm-charts/issues/409)) ([603d76f](https://github.com/Mailu/helm-charts/commit/603d76f02a9906e0a80356d5baeef69bc89e84ba))


## [2.1.2](https://github.com/Mailu/helm-charts/compare/mailu-2.1.1...mailu-2.1.2) (2024-12-22)


### Bug Fixes

* Allow setting custom NodePorts for externalService ([#383](https://github.com/Mailu/helm-charts/issues/383)) ([0b1a9cd](https://github.com/Mailu/helm-charts/commit/0b1a9cda3448f2735460f2aa1c79b50a8f6d38c0))
* Fix issue with redis subpath needing to be relative ([#376](https://github.com/Mailu/helm-charts/issues/376)) ([0fd99a6](https://github.com/Mailu/helm-charts/commit/0fd99a668bcb32f710bdbce729f38074895d8273))

## [2.1.1](https://github.com/Mailu/helm-charts/compare/mailu-2.1.0...mailu-2.1.1) (2024-08-20)


### Bug Fixes

* bump mailu to 2024.06.6 ([#359](https://github.com/Mailu/helm-charts/issues/359)) ([cfc2b7b](https://github.com/Mailu/helm-charts/commit/cfc2b7bf2425ac6e05574da48ee13b29b0307d32))
* bump mailu version to 2024.06.10 ([#365](https://github.com/Mailu/helm-charts/issues/365)) ([b10d394](https://github.com/Mailu/helm-charts/commit/b10d39463d033c47c82d8b3d1c53acac94c2d926))

## [2.1.0](https://github.com/Mailu/helm-charts/compare/mailu-2.0.0...mailu-2.1.0) (2024-07-28)


### Features

* added Tika support ([#356](https://github.com/Mailu/helm-charts/issues/356)) ([34ef061](https://github.com/Mailu/helm-charts/commit/34ef061e9f2c3a906dc198b9fe430361f3a3554f))
* enable API support ([#358](https://github.com/Mailu/helm-charts/issues/358)) ([0d313fa](https://github.com/Mailu/helm-charts/commit/0d313fa5f307f076d3389075d3dac189383895ad))
* several fixes for Mailu 2024.06 support ([#354](https://github.com/Mailu/helm-charts/issues/354)) ([3fa16db](https://github.com/Mailu/helm-charts/commit/3fa16db195f3361388c4b9cee329c0e67970dc9a))

## [2.0.0](https://github.com/Mailu/helm-charts/compare/mailu-1.5.0...mailu-2.0.0) (2024-06-24)


### ⚠ BREAKING CHANGES

* replace mailu clamav container with official container ([#350](https://github.com/Mailu/helm-charts/issues/350))

### Features

* add extraContainers to helm chart in order to allow users to inject sidecar-containers to each component ([#344](https://github.com/Mailu/helm-charts/issues/344)) ([369a6cd](https://github.com/Mailu/helm-charts/commit/369a6cd3c17c9734d44e74857f96a77700228a40))
* add the possibility to disable RSPAMD ([#337](https://github.com/Mailu/helm-charts/issues/337)) ([bb5a3ab](https://github.com/Mailu/helm-charts/commit/bb5a3ab6cb919f6334973430ad1175775f8ac829))
* bump mailu version to 2024.06.3 ([#351](https://github.com/Mailu/helm-charts/issues/351)) ([d35ecce](https://github.com/Mailu/helm-charts/commit/d35ecce77e4c31d379fc9632e57d3db73b53eeb8))
* replace mailu clamav container with official container ([#350](https://github.com/Mailu/helm-charts/issues/350)) ([b45bd55](https://github.com/Mailu/helm-charts/commit/b45bd55fe61013a14ff2576eda86ff956bf1055c))


### Bug Fixes

* remove duplicate 'get secrets' in notes ([#345](https://github.com/Mailu/helm-charts/issues/345)) ([1d3cec3](https://github.com/Mailu/helm-charts/commit/1d3cec3f72f372dd0e1116c54ab64557fcfb9f7e))

## [1.5.0](https://github.com/Mailu/helm-charts/compare/mailu-1.4.0...mailu-1.5.0) (2023-10-24)


### Features

* add MAILU_HELM_CHART environment variable ([#312](https://github.com/Mailu/helm-charts/issues/312)) ([e26ffd7](https://github.com/Mailu/helm-charts/commit/e26ffd7c70a8788db93cb48cbf48d51a33a8eb8a))
* bump mailu version to 2.0.30 ([#314](https://github.com/Mailu/helm-charts/issues/314)) ([4884ca4](https://github.com/Mailu/helm-charts/commit/4884ca4d0e030038f262d569b15bca550b404539))

## [1.4.0](https://github.com/Mailu/helm-charts/compare/mailu-1.3.0...mailu-1.4.0) (2023-08-29)


### Features

* bump mailu version to 2.0.22 ([#296](https://github.com/Mailu/helm-charts/issues/296)) ([17d3b94](https://github.com/Mailu/helm-charts/commit/17d3b94558f795e0f7f43804f51e23285f8c8075))

## [1.3.0](https://github.com/Mailu/helm-charts/compare/mailu-1.2.0...mailu-1.3.0) (2023-08-24)


### Features

* add securityContext and podSecurityContext options ([#263](https://github.com/Mailu/helm-charts/issues/263)) ([6f9e25b](https://github.com/Mailu/helm-charts/commit/6f9e25bba7c7f69e84af6f6cd13fb7648bb5fe0c))
* dynamic shields ([0651568](https://github.com/Mailu/helm-charts/commit/065156800f661c522a7d89a2c77b107a5f859356))
* upgrade mailu version to 2.0.20 ([#294](https://github.com/Mailu/helm-charts/issues/294)) ([d7fc85c](https://github.com/Mailu/helm-charts/commit/d7fc85cbc4b68a496a7f9ddc2fdc50d85fac4206))


### Bug Fixes

* fix postgresql initdb script ([#258](https://github.com/Mailu/helm-charts/issues/258)) ([04b803a](https://github.com/Mailu/helm-charts/commit/04b803a83e89f17a7fc247ebec0b4cd06fbbc73a))
* fixed probes ([#289](https://github.com/Mailu/helm-charts/issues/289)) ([76c333c](https://github.com/Mailu/helm-charts/commit/76c333c7682536141262255754b74f1065609f17))
* only include roudcube secrets if webmail.enabled is set to true ([#272](https://github.com/Mailu/helm-charts/issues/272)) ([5e652c0](https://github.com/Mailu/helm-charts/commit/5e652c0b2b5db10032320e7b9e805c711cc6853f))
* readinessProbe.enabled has no effect ([b33d602](https://github.com/Mailu/helm-charts/commit/b33d60238aaf83fe322c1d100e3b9d4b2cae6ecd))
* set default permanentSessionLifetime to 30 days instead of 30 hours ([180109f](https://github.com/Mailu/helm-charts/commit/180109f96ff3f9bea39890998a65ab501690cba8))

## [1.2.0](https://github.com/Mailu/helm-charts/compare/mailu-1.1.1...mailu-1.2.0) (2023-05-01)


### Features

* Add proxyAuth section to values to configure PROXY_AUTH_* env vars ([04825ef](https://github.com/Mailu/helm-charts/commit/04825ef1457ae34e2b0471fefd04397df4ba4a01))


### Bug Fixes

* bumped Mailu version to 2.0.10 ([f70466c](https://github.com/Mailu/helm-charts/commit/f70466cde9d11891593d0ecb25b5b1d3bf69a11d))
* fixed dovecot probes ([b1b0405](https://github.com/Mailu/helm-charts/commit/b1b0405681350a85464cf3d69c3bc28355f7d8c5))
* fixed readme and generator ([98c21c7](https://github.com/Mailu/helm-charts/commit/98c21c79a68d0aef21c2022d2eb562e232456086))

## [1.1.1](https://github.com/Mailu/helm-charts/compare/mailu-1.1.0...mailu-1.1.1) (2023-04-19)


### Bug Fixes

* [BUG] Helm error when deploying with webdav.enabled=true because of missing template [#232](https://github.com/Mailu/helm-charts/issues/232) ([91cd49e](https://github.com/Mailu/helm-charts/commit/91cd49e57166f1d64f2e667b96efe5ba1f01d7c1))
* [BUG] postfix-overrides ConfigMap will never render [#234](https://github.com/Mailu/helm-charts/issues/234) ([bc73acc](https://github.com/Mailu/helm-charts/commit/bc73acca4f24d162716c73fad6833ffb7dbf9f02))
* fixed encoding of relayuser and relaypassword ([0209240](https://github.com/Mailu/helm-charts/commit/02092404f1d060699fff81554b54872bcfbb6479))
* fixed typo in fetchmail deployment ([baca17a](https://github.com/Mailu/helm-charts/commit/baca17a2c12019a8504f3a72b17809690c2d79fc))
* fixed typo when external service set to NodePort ([741a90d](https://github.com/Mailu/helm-charts/commit/741a90daf10d45f181e253f06c863919b00e9dc3))

## [1.1.0](https://github.com/Mailu/helm-charts/compare/mailu-1.0.1...mailu-1.1.0) (2023-04-13)


### Features

* Add support for TLS settings ([07fad3a](https://github.com/Mailu/helm-charts/commit/07fad3a81bb823ca979afdc1dca0d4944d4e7775))
* Added oletools component ([0a4f95f](https://github.com/Mailu/helm-charts/commit/0a4f95f3d0d42a5a42b9d3db612ff6afb2a62628))
* Added support for WILDCARD_SENDERS ([f72db8d](https://github.com/Mailu/helm-charts/commit/f72db8d78dd0de4d77ad8085dfafe5de0f38cab8))


### Bug Fixes

* Fixed sieve support ([91792ff](https://github.com/Mailu/helm-charts/commit/91792ffbc0811d1c0252603c53c17d1e25d646a6))
* Restrict web ports to ingress-nginx when network policies are enabled ([e21cc8b](https://github.com/Mailu/helm-charts/commit/e21cc8bcdecfcba509bfaea01609858393a2730e))

## [1.0.1](https://github.com/Mailu/helm-charts/compare/mailu-1.0.0...mailu-1.0.1) (2023-04-13)


### Bug Fixes

* Fixed Dovecot probes ([41f3497](https://github.com/Mailu/helm-charts/commit/41f349766e5c7a4084befd0b2b62a6c3081f5e6b))

## [1.0.0](https://github.com/Mailu/helm-charts/compare/mailu-1.0.0-beta.32...mailu-1.0.0) (2023-04-12)


### Miscellaneous Chores

* Release 1.0.0 ([db41cf5](https://github.com/Mailu/helm-charts/commit/db41cf50d6567177aa13e2ff43320c8df733e8e0))

## [1.0.0-beta.32](https://github.com/Mailu/helm-charts/compare/mailu-1.0.0-beta.31...mailu-1.0.0-beta.32) (2023-04-12)


### Miscellaneous Chores

* release 1.0.0-beta.32 ([b31d9f4](https://github.com/Mailu/helm-charts/commit/b31d9f4bbdd8d7ff161e3fadd689798e91437fd7))

## [1.0.0-beta.31](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.30...mailu-1.0.0-beta.31) (2023-04-07)


### Bug Fixes

* cleaned env vars for addresses ([11eeea0](https://github.com/fastlorenzo/helm-charts-1/commit/11eeea0738cd56ef881acfa1f0dfe850733ebce3))
* cleaned env vars for addresses ([#65](https://github.com/fastlorenzo/helm-charts-1/issues/65)) ([1768f6a](https://github.com/fastlorenzo/helm-charts-1/commit/1768f6abf94a61e7379202f4815f8c775cf1774d))
* Fixed env var for antispam ([c180724](https://github.com/fastlorenzo/helm-charts-1/commit/c18072403f204c68aa2766c29f44255f0aa310a3))
* Fixed env var for antispam ([#63](https://github.com/fastlorenzo/helm-charts-1/issues/63)) ([00e62e6](https://github.com/fastlorenzo/helm-charts-1/commit/00e62e65011ffe748061fcc1ef126cc9d88678e9))


### Miscellaneous Chores

* release 1.0.0-beta.31 ([87fa8e8](https://github.com/fastlorenzo/helm-charts-1/commit/87fa8e8b96fca5cbaf0cef08d094ba3f51dd4233))

## [1.0.0-beta.30](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.29...mailu-1.0.0-beta.30) (2023-04-07)


### Miscellaneous Chores

* release 1.0.0-beta.30 ([0e7c8af](https://github.com/fastlorenzo/helm-charts-1/commit/0e7c8af3d49fdd874a31d82a19db910197ed77ad))

## [1.0.0-beta.29](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.28...mailu-1.0.0-beta.29) (2023-03-17)


### Bug Fixes

* add missing container registry for admin ([1cb6a88](https://github.com/fastlorenzo/helm-charts-1/commit/1cb6a887518e115761ea0260b675969e60ea3ba1))
* Add missing container registry for admin ([a051d71](https://github.com/fastlorenzo/helm-charts-1/commit/a051d7196ee3cebbf7175395eb65374cea877cb0))
* Add missing container registry for admin ([a051d71](https://github.com/fastlorenzo/helm-charts-1/commit/a051d7196ee3cebbf7175395eb65374cea877cb0))


### Miscellaneous Chores

* release 1.0.0-beta.29 ([4892a2a](https://github.com/fastlorenzo/helm-charts-1/commit/4892a2a5757697d5ffc47bd2e6590f65fdad4898))

## [1.0.0-beta.28](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.27...mailu-1.0.0-beta.28) (2023-03-17)


### Bug Fixes

* migrate container registry to ghcr.io ([77ad28a](https://github.com/fastlorenzo/helm-charts-1/commit/77ad28a41c9e956fd538f949bab0d36dcd1d9237))
* Unset default value for realIpFrom ([#53](https://github.com/fastlorenzo/helm-charts-1/issues/53)) ([1d1aa9a](https://github.com/fastlorenzo/helm-charts-1/commit/1d1aa9ac6a2ffbd3729cca8d44e431554b468f57))
* Updated documentation ([#55](https://github.com/fastlorenzo/helm-charts-1/issues/55)) ([7c52126](https://github.com/fastlorenzo/helm-charts-1/commit/7c521269611c22bad2070b67544e2a6bc162b647))


### Miscellaneous Chores

* release 1.0.0-beta.28 ([dff244e](https://github.com/fastlorenzo/helm-charts-1/commit/dff244e2cd61a01fa1de4b11d101f7c3db67b4b9))

## [1.0.0-beta.27](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.26...mailu-1.0.0-beta.27) (2022-12-14)


### Features

* Refactor env vars ([#50](https://github.com/fastlorenzo/helm-charts-1/issues/50)) ([07feb7a](https://github.com/fastlorenzo/helm-charts-1/commit/07feb7a2c07e3127bac8f90fe5a283adb35817bb))


### Miscellaneous Chores

* release 1.0.0-beta.27 ([607c463](https://github.com/fastlorenzo/helm-charts-1/commit/607c463f0a01b865bc8189d7ad6360e71c99e2cb))

## [1.0.0-beta.26](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.25...mailu-1.0.0-beta.26) (2022-12-11)


### Bug Fixes

* Added extra volumes for all pods ([#48](https://github.com/fastlorenzo/helm-charts-1/issues/48)) ([a466bb0](https://github.com/fastlorenzo/helm-charts-1/commit/a466bb005d6e3ce054edc0ea4b976b0dd89297bf))


### Miscellaneous Chores

* release 1.0.0-beta.26 ([50b5a28](https://github.com/fastlorenzo/helm-charts-1/commit/50b5a287b581f7ac7fa91c988b947fbbe2358856))

## [1.0.0-beta.25](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.24...mailu-1.0.0-beta.25) (2022-12-08)


### Features

* add support for network policy ([8fd3c6c](https://github.com/fastlorenzo/helm-charts-1/commit/8fd3c6c527a692983e54c82511c6e77fc9150df4))
* add support for network policy ([7e42d15](https://github.com/fastlorenzo/helm-charts-1/commit/7e42d15df88d43213e672235e366edbfb53532c6))
* add support for network policy ([#46](https://github.com/fastlorenzo/helm-charts-1/issues/46)) ([e42623b](https://github.com/fastlorenzo/helm-charts-1/commit/e42623b11b3bdde6c7c3678d5a1450e0af18e76d))


### Bug Fixes

* add compatibility with latest Mailu master branch ([#44](https://github.com/fastlorenzo/helm-charts-1/issues/44)) ([25eb5e5](https://github.com/fastlorenzo/helm-charts-1/commit/25eb5e5130a66457400cdffacffde93649af6e63))
* fixed compatibility with Mailu master ([1a66cb5](https://github.com/fastlorenzo/helm-charts-1/commit/1a66cb545a5c47359069e1e6cf78a0556567b877))


### Miscellaneous Chores

* release 1.0.0-beta.25 ([cd96738](https://github.com/fastlorenzo/helm-charts-1/commit/cd96738b188af220758f3fa436dd8ae32a3e6655))
* release 1.0.0-beta.25 ([6129948](https://github.com/fastlorenzo/helm-charts-1/commit/61299485da7eac6456248baa24400c3e35ead737))

## [1.0.0-beta.24](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.23...mailu-1.0.0-beta.24) (2022-11-22)


### Features

* Add Rspamd overrides [#38](https://github.com/fastlorenzo/helm-charts-1/issues/38) ([7c25309](https://github.com/fastlorenzo/helm-charts-1/commit/7c25309841252793199b650ce00cda1287daa755))


### Bug Fixes

* Fix postfix override settings ([6852d19](https://github.com/fastlorenzo/helm-charts-1/commit/6852d1924178260703f0b780358b24abf7bf1bf4))
* Fixed usage of existingSecret for TLS (fixes [#37](https://github.com/fastlorenzo/helm-charts-1/issues/37)) ([cbb84c7](https://github.com/fastlorenzo/helm-charts-1/commit/cbb84c78d99edb61102b21a0822f236f5f7f6b36))


### Miscellaneous Chores

* release 1.0.0-beta.24 ([b54e6e8](https://github.com/fastlorenzo/helm-charts-1/commit/b54e6e8b31d858134255d74526791c09a4e26fb5))

## [1.0.0-beta.23](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.22...mailu-1.0.0-beta.23) (2022-11-18)


### Bug Fixes

* fixed missing check when using existing claim ([#34](https://github.com/fastlorenzo/helm-charts-1/issues/34)) ([8f36df0](https://github.com/fastlorenzo/helm-charts-1/commit/8f36df0ff0a7cbec6be444e58c21421009acfd4e))


### Miscellaneous Chores

* release 1.0.0-beta.23 ([a6a86e1](https://github.com/fastlorenzo/helm-charts-1/commit/a6a86e1d7bf729c6e4e92676f6369b2922b87fd0))

## [1.0.0-beta.22](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.21...mailu-1.0.0-beta.22) (2022-11-09)


### Miscellaneous Chores

* release 1.0.0-beta.22 ([9e996a2](https://github.com/fastlorenzo/helm-charts-1/commit/9e996a20f654a90c6d65a30f8b86e2044b5c92e4))

## [1.0.0-beta.21](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.20...mailu-1.0.0-beta.21) (2022-11-09)


### Bug Fixes

* Fixed typo in nodePort param ([cd29882](https://github.com/fastlorenzo/helm-charts-1/commit/cd298824d73079b0dae7deecf265b0fa4780c8e5))
* Fixed typo in nodePort param ([#29](https://github.com/fastlorenzo/helm-charts-1/issues/29)) ([bc159d0](https://github.com/fastlorenzo/helm-charts-1/commit/bc159d029d211d62a5730a7dbb4b179091824743))


### Miscellaneous Chores

* release 1.0.0-beta.21 ([87b2041](https://github.com/fastlorenzo/helm-charts-1/commit/87b2041bbba6e124119c196cca24d9b83f8bd805))

## [1.0.0-beta.20](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.19...mailu-1.0.0-beta.20) (2022-11-09)


### Bug Fixes

* fixed typo in external service ([0ec88b1](https://github.com/fastlorenzo/helm-charts-1/commit/0ec88b18a6cdbce99d37e065cd7bd472a82013f9))
* fixed typo in external service ([#27](https://github.com/fastlorenzo/helm-charts-1/issues/27)) ([a2efb99](https://github.com/fastlorenzo/helm-charts-1/commit/a2efb9955838ea4f1399238e5dabfe3956c79700))


### Miscellaneous Chores

* release 1.0.0-beta.20 ([69697aa](https://github.com/fastlorenzo/helm-charts-1/commit/69697aaa79c4a8b9662a71d7d5ed29060fafdf2a))

## [1.0.0-beta.19](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.18...mailu-1.0.0-beta.19) (2022-11-09)


### Features

* Added support for NodePort for front External Service ([551c9ae](https://github.com/fastlorenzo/helm-charts-1/commit/551c9ae0d791acb67f6a31af7d9d409fe2c07cf6))
* Added support for NodePort for front External Service ([#25](https://github.com/fastlorenzo/helm-charts-1/issues/25)) ([b9a1b84](https://github.com/fastlorenzo/helm-charts-1/commit/b9a1b8446a1452d3c54d4ecf828d8fa7adf1f851))


### Miscellaneous Chores

* release 1.0.0-beta.19 ([f3d223c](https://github.com/fastlorenzo/helm-charts-1/commit/f3d223c565eff6aa7ec0821ce38e3f2c536f75eb))

## [1.0.0-beta.18](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.17...mailu-1.0.0-beta.18) (2022-11-08)


### Features

* added support for redis external database ([88c1b0d](https://github.com/fastlorenzo/helm-charts-1/commit/88c1b0da26a94de6b31a98fad707d897c5f095cb))
* added support for redis external database ([#23](https://github.com/fastlorenzo/helm-charts-1/issues/23)) ([7096a13](https://github.com/fastlorenzo/helm-charts-1/commit/7096a134f4f4008436075811807808a4b74dd2ce))


### Bug Fixes

* updated helm dependency ([c776220](https://github.com/fastlorenzo/helm-charts-1/commit/c77622074e7314301d58a02efa00c5d3928772c5))


### Miscellaneous Chores

* release 1.0.0-beta.18 ([9065a20](https://github.com/fastlorenzo/helm-charts-1/commit/9065a202fe89ea2ac35f07291a973301c4b35f63))

## [1.0.0-beta.17](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.16...mailu-1.0.0-beta.17) (2022-11-08)


### Miscellaneous Chores

* release 1.0.0-beta.17 ([14c48ee](https://github.com/fastlorenzo/helm-charts-1/commit/14c48ee3ea651d0c7a1fc6896bb5a06408250d55))

## [1.0.0-beta.16](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.15...mailu-1.0.0-beta.16) (2022-11-08)


### Miscellaneous Chores

* release 1.0.0-beta.16 ([3752e90](https://github.com/fastlorenzo/helm-charts-1/commit/3752e90a310cb1ac1c4bbd7007d868e2618ebb2f))

## [1.0.0-beta.15](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.14...mailu-1.0.0-beta.15) (2022-11-08)


### Bug Fixes

* fixed syntax ([fb13f1e](https://github.com/fastlorenzo/helm-charts-1/commit/fb13f1eebf01aa98baf177efa74af6d69df028f1))


### Miscellaneous Chores

* release 1.0.0-beta.15 ([24493f6](https://github.com/fastlorenzo/helm-charts-1/commit/24493f6bea127e2b474b5449a525e375079dc147))

## [1.0.0-beta.14](https://github.com/fastlorenzo/helm-charts-1/compare/mailu-1.0.0-beta.13...mailu-1.0.0-beta.14) (2022-11-08)


### Bug Fixes

* Added keyword for roundcube ([4bf6ba9](https://github.com/fastlorenzo/helm-charts-1/commit/4bf6ba9d8e116d0da959e9df79230454fe3d6e12))
* changed debug mode to WARNING in CI values ([7e84c2a](https://github.com/fastlorenzo/helm-charts-1/commit/7e84c2ac3a72ce84b94ed8addafb9dcce9db02ba))
* force release ([8ed1e96](https://github.com/fastlorenzo/helm-charts-1/commit/8ed1e9638e38f76521473a965b91e1f954400eb4))
