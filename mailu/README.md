# mailu

![Version: 0.3.3](https://img.shields.io/badge/Version-0.3.3-informational?style=flat-square) ![AppVersion: 1.9](https://img.shields.io/badge/AppVersion-1.9-informational?style=flat-square)

This chart installs the Mailu mail system on kubernetes

**Homepage:** <https://mailu.io>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mariadb | 11.3.* |
| https://charts.bitnami.com/bitnami | postgresql | 11.9.* |

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

<table height="400px" >
	<thead>
		<th>Key</th>
		<th>Type</th>
		<th>Default</th>
		<th>Description</th>
	</thead>
	<tbody>
		<tr>
			<td id="admin--affinity"><a href="./values.yaml#L427">admin.affinity</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Affinity for admin pod assignment</td>
		</tr>
		<tr>
			<td id="admin--extraEnvVars"><a href="./values.yaml#L345">admin.extraEnvVars</a></td>
			<td>
list
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Extra environment variable to pass to the running container.</td>
		</tr>
		<tr>
			<td id="admin--extraEnvVarsCM"><a href="./values.yaml#L348">admin.extraEnvVarsCM</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Name of existing ConfigMap containing extra env vars for Mailu admin pod(s)</td>
		</tr>
		<tr>
			<td id="admin--extraEnvVarsSecret"><a href="./values.yaml#L351">admin.extraEnvVarsSecret</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Name of existing Secret containing extra env vars for Mailu admin pod(s)</td>
		</tr>
		<tr>
			<td id="admin--image--pullPolicy"><a href="./values.yaml#L323">admin.image.pullPolicy</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"IfNotPresent"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--image--repository"><a href="./values.yaml#L320">admin.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/admin"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--image--tag"><a href="./values.yaml#L322">admin.image.tag</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>tag defaults to mailuVersion</td>
		</tr>
		<tr>
			<td id="admin--initContainers"><a href="./values.yaml#L420">admin.initContainers</a></td>
			<td>
list
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Add additional init containers to the Mailu Admin pod(s)</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--enabled"><a href="./values.yaml#L356">admin.livenessProbe.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Enable livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--failureThreshold"><a href="./values.yaml#L358">admin.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td>Failure threshold for livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--initialDelaySeconds"><a href="./values.yaml#L360">admin.livenessProbe.initialDelaySeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Initial delay seconds for livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--periodSeconds"><a href="./values.yaml#L362">admin.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Period seconds for livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--successThreshold"><a href="./values.yaml#L364">admin.livenessProbe.successThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Success threshold for livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--livenessProbe--timeoutSeconds"><a href="./values.yaml#L366">admin.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Timeout seconds for livenessProbe</td>
		</tr>
		<tr>
			<td id="admin--nodeSelector"><a href="./values.yaml#L410">admin.nodeSelector</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Node labels for admin pod assignment</td>
		</tr>
		<tr>
			<td id="admin--persistence--accessMode"><a href="./values.yaml#L327">admin.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--persistence--claimNameOverride"><a href="./values.yaml#L328">admin.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--persistence--size"><a href="./values.yaml#L325">admin.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--persistence--storageClass"><a href="./values.yaml#L326">admin.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--podAnnotations"><a href="./values.yaml#L406">admin.podAnnotations</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Admin Pod annotations</td>
		</tr>
		<tr>
			<td id="admin--podLabels"><a href="./values.yaml#L402">admin.podLabels</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Admin Pod labels</td>
		</tr>
		<tr>
			<td id="admin--priorityClassName"><a href="./values.yaml#L423">admin.priorityClassName</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Mailu admin pods' priorityClassName</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--enabled"><a href="./values.yaml#L372">admin.readinessProbe.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Enable readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--failureThreshold"><a href="./values.yaml#L374">admin.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td>Failure threshold for readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L376">admin.readinessProbe.initialDelaySeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Initial delay seconds for readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--periodSeconds"><a href="./values.yaml#L378">admin.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Period seconds for readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--successThreshold"><a href="./values.yaml#L380">admin.readinessProbe.successThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Success threshold for readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--readinessProbe--timeoutSeconds"><a href="./values.yaml#L382">admin.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Timeout seconds for readinessProbe</td>
		</tr>
		<tr>
			<td id="admin--resources--limits--cpu"><a href="./values.yaml#L338">admin.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--resources--limits--memory"><a href="./values.yaml#L337">admin.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--resources--requests--cpu"><a href="./values.yaml#L335">admin.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--resources--requests--memory"><a href="./values.yaml#L334">admin.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="admin--service--annotations"><a href="./values.yaml#L436">admin.service.annotations</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Admin service annotations</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--enabled"><a href="./values.yaml#L388">admin.startupProbe.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Enable startupProbe</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--failureThreshold"><a href="./values.yaml#L390">admin.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td>Failure threshold for startupProbe</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--initialDelaySeconds"><a href="./values.yaml#L392">admin.startupProbe.initialDelaySeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Initial delay seconds for startupProbe</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--periodSeconds"><a href="./values.yaml#L394">admin.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td>Period seconds for startupProbe</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--successThreshold"><a href="./values.yaml#L396">admin.startupProbe.successThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Success threshold for startupProbe</td>
		</tr>
		<tr>
			<td id="admin--startupProbe--timeoutSeconds"><a href="./values.yaml#L398">admin.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td>Timeout seconds for startupProbe</td>
		</tr>
		<tr>
			<td id="admin--tolerations"><a href="./values.yaml#L431">admin.tolerations</a></td>
			<td>
list
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>admin.tolerations Tolerations for admin pod assignment</td>
		</tr>
		<tr>
			<td id="affinity"><a href="./values.yaml#L54">affinity</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Affinity for pod assignment</td>
		</tr>
		<tr>
			<td id="certmanager"><a href="./values.yaml#L244">certmanager</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{
  "apiVersion": "cert-manager.io/v1",
  "enabled": true,
  "issuerName": "letsencrypt",
  "issuerType": "ClusterIssuer"
}
</pre>
</div>
			</td>
			<td>certmanager settings</td>
		</tr>
		<tr>
			<td id="clamav--enabled"><a href="./values.yaml#L607">clamav.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--image--repository"><a href="./values.yaml#L610">clamav.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/clamav"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--livenessProbe--failureThreshold"><a href="./values.yaml#L633">clamav.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--livenessProbe--periodSeconds"><a href="./values.yaml#L632">clamav.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--livenessProbe--timeoutSeconds"><a href="./values.yaml#L634">clamav.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--persistence--accessMode"><a href="./values.yaml#L616">clamav.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--persistence--claimNameOverride"><a href="./values.yaml#L617">clamav.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--persistence--size"><a href="./values.yaml#L614">clamav.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"2Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--persistence--storageClass"><a href="./values.yaml#L615">clamav.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--readinessProbe--failureThreshold"><a href="./values.yaml#L637">clamav.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--readinessProbe--periodSeconds"><a href="./values.yaml#L636">clamav.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--readinessProbe--timeoutSeconds"><a href="./values.yaml#L638">clamav.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--resources--limits--cpu"><a href="./values.yaml#L626">clamav.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"1000m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--resources--limits--memory"><a href="./values.yaml#L625">clamav.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"2Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--resources--requests--cpu"><a href="./values.yaml#L623">clamav.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"1000m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--resources--requests--memory"><a href="./values.yaml#L622">clamav.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"1Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--startupProbe--failureThreshold"><a href="./values.yaml#L629">clamav.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
60
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--startupProbe--periodSeconds"><a href="./values.yaml#L628">clamav.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clamav--startupProbe--timeoutSeconds"><a href="./values.yaml#L630">clamav.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="clusterDomain"><a href="./values.yaml#L44">clusterDomain</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"cluster.local"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--mysql"><a href="./values.yaml#L91">database.mysql</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--postgresql"><a href="./values.yaml#L109">database.postgresql</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--roundcube--database"><a href="./values.yaml#L67">database.roundcube.database</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"roundcube"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--roundcube--password"><a href="./values.yaml#L69">database.roundcube.password</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"changeme"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--roundcube--type"><a href="./values.yaml#L66">database.roundcube.type</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"sqlite"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--roundcube--username"><a href="./values.yaml#L68">database.roundcube.username</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"roundcube"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="database--type"><a href="./values.yaml#L60">database.type</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"sqlite"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="domain"><a href="./values.yaml#L13">domain</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Mail domain name. See https://github.com/Mailu/Mailu/blob/master/docs/faq.rst#what-is-the-difference-between-domain-and-hostnames</td>
		</tr>
		<tr>
			<td id="dovecot--containerSecurityContext"><a href="./values.yaml#L513">dovecot.containerSecurityContext</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--enabled"><a href="./values.yaml#L507">dovecot.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--image--repository"><a href="./values.yaml#L510">dovecot.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/dovecot"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--livenessProbe--failureThreshold"><a href="./values.yaml#L538">dovecot.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--livenessProbe--periodSeconds"><a href="./values.yaml#L537">dovecot.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--livenessProbe--timeoutSeconds"><a href="./values.yaml#L539">dovecot.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--persistence--accessMode"><a href="./values.yaml#L521">dovecot.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--persistence--claimNameOverride"><a href="./values.yaml#L522">dovecot.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--persistence--size"><a href="./values.yaml#L519">dovecot.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--persistence--storageClass"><a href="./values.yaml#L520">dovecot.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--readinessProbe--failureThreshold"><a href="./values.yaml#L542">dovecot.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--readinessProbe--periodSeconds"><a href="./values.yaml#L541">dovecot.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--readinessProbe--timeoutSeconds"><a href="./values.yaml#L543">dovecot.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--resources--limits--cpu"><a href="./values.yaml#L531">dovecot.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--resources--limits--memory"><a href="./values.yaml#L530">dovecot.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--resources--requests--cpu"><a href="./values.yaml#L528">dovecot.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--resources--requests--memory"><a href="./values.yaml#L527">dovecot.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--startupProbe--failureThreshold"><a href="./values.yaml#L534">dovecot.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--startupProbe--periodSeconds"><a href="./values.yaml#L533">dovecot.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="dovecot--startupProbe--timeoutSeconds"><a href="./values.yaml#L535">dovecot.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="existingSecret"><a href="./values.yaml#L25">existingSecret</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>existingSecret Name of the existing secret to retrieve the secretKey. The secret has to contain the secretKey value under the `secret-key` key.</td>
		</tr>
		<tr>
			<td id="external_relay"><a href="./values.yaml#L194">external_relay</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--delay"><a href="./values.yaml#L770">fetchmail.delay</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
600
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--enabled"><a href="./values.yaml#L750">fetchmail.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Enable deployment of fetchmail</td>
		</tr>
		<tr>
			<td id="fetchmail--image--repository"><a href="./values.yaml#L753">fetchmail.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/fetchmail"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--persistence--accessMode"><a href="./values.yaml#L759">fetchmail.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--persistence--claimNameOverride"><a href="./values.yaml#L760">fetchmail.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--persistence--size"><a href="./values.yaml#L757">fetchmail.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--persistence--storageClass"><a href="./values.yaml#L758">fetchmail.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--resources--limits--cpu"><a href="./values.yaml#L769">fetchmail.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--resources--limits--memory"><a href="./values.yaml#L768">fetchmail.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--resources--requests--cpu"><a href="./values.yaml#L766">fetchmail.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fetchmail--resources--requests--memory"><a href="./values.yaml#L765">fetchmail.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--controller--kind"><a href="./values.yaml#L290">front.controller.kind</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"Deployment"
</pre>
</div>
			</td>
			<td>Deployment or DaemonSet</td>
		</tr>
		<tr>
			<td id="front--externalService--annotations"><a href="./values.yaml#L305">front.externalService.annotations</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--enabled"><a href="./values.yaml#L299">front.externalService.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--externalTrafficPolicy"><a href="./values.yaml#L304">front.externalService.externalTrafficPolicy</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"Local"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--imap--imap"><a href="./values.yaml#L310">front.externalService.imap.imap</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--imap--imaps"><a href="./values.yaml#L311">front.externalService.imap.imaps</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--pop3--pop3"><a href="./values.yaml#L307">front.externalService.pop3.pop3</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--pop3--pop3s"><a href="./values.yaml#L308">front.externalService.pop3.pop3s</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--smtp--smtp"><a href="./values.yaml#L313">front.externalService.smtp.smtp</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--smtp--smtps"><a href="./values.yaml#L314">front.externalService.smtp.smtps</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--smtp--submission"><a href="./values.yaml#L315">front.externalService.smtp.submission</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--externalService--type"><a href="./values.yaml#L300">front.externalService.type</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ClusterIP"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--hostPort"><a href="./values.yaml#L294">front.hostPort</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{
  "enabled": true
}
</pre>
</div>
			</td>
			<td>Expose front mail ports via hostPort</td>
		</tr>
		<tr>
			<td id="front--image--repository"><a href="./values.yaml#L264">front.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/nginx"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--image--tag"><a href="./values.yaml#L267">front.image.tag</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
defaults to mailuVersion
</pre>
</div>
			</td>
			<td>Fron pod image tag</td>
		</tr>
		<tr>
			<td id="front--livenessProbe--failureThreshold"><a href="./values.yaml#L281">front.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--livenessProbe--periodSeconds"><a href="./values.yaml#L280">front.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--livenessProbe--timeoutSeconds"><a href="./values.yaml#L282">front.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--nodeSelector"><a href="./values.yaml#L291">front.nodeSelector</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--readinessProbe--failureThreshold"><a href="./values.yaml#L285">front.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--readinessProbe--periodSeconds"><a href="./values.yaml#L284">front.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--readinessProbe--timeoutSeconds"><a href="./values.yaml#L286">front.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--resources--limits--cpu"><a href="./values.yaml#L274">front.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--resources--limits--memory"><a href="./values.yaml#L273">front.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--resources--requests--cpu"><a href="./values.yaml#L271">front.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--resources--requests--memory"><a href="./values.yaml#L270">front.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--startupProbe--failureThreshold"><a href="./values.yaml#L277">front.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--startupProbe--periodSeconds"><a href="./values.yaml#L276">front.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="front--startupProbe--timeoutSeconds"><a href="./values.yaml#L278">front.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="fullnameOverride"><a href="./values.yaml#L43">fullnameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="hostnames"><a href="./values.yaml#L8">hostnames</a></td>
			<td>
list
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>List of hostnames to generate certificates and ingresses for. The first will be used as primary mail hostname</td>
		</tr>
		<tr>
			<td id="ingress"><a href="./values.yaml#L251">ingress</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{
  "annotations": {
    "nginx.ingress.kubernetes.io/proxy-body-size": "0"
  },
  "className": "",
  "externalIngress": true,
  "realIpFrom": "0.0.0.0/0",
  "realIpHeader": "X-Forwarded-For",
  "tlsFlavor": "cert"
}
</pre>
</div>
			</td>
			<td>Set ingress and loadbalancer config</td>
		</tr>
		<tr>
			<td id="initialAccount"><a href="./values.yaml#L40">initialAccount</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>An initial account can automatically be created:</td>
		</tr>
		<tr>
			<td id="logLevel"><a href="./values.yaml#L223">logLevel</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"WARNING"
</pre>
</div>
			</td>
			<td>default log level. can be overridden globally or per service</td>
		</tr>
		<tr>
			<td id="mail--authRatelimitExemtionLength"><a href="./values.yaml#L236">mail.authRatelimitExemtionLength</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
86400
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mail--authRatelimitIP"><a href="./values.yaml#L232">mail.authRatelimitIP</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"60/hour"
</pre>
</div>
			</td>
			<td>Configuration to prevent brute-force attacks. See the documentation for further information: https://mailu.io/master/configuration.html</td>
		</tr>
		<tr>
			<td id="mail--authRatelimitIPv4Mask"><a href="./values.yaml#L233">mail.authRatelimitIPv4Mask</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
24
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mail--authRatelimitIPv6Mask"><a href="./values.yaml#L234">mail.authRatelimitIPv6Mask</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
56
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mail--authRatelimitUser"><a href="./values.yaml#L235">mail.authRatelimitUser</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100/day"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mail--messageRatelimit"><a href="./values.yaml#L240">mail.messageRatelimit</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200/day"
</pre>
</div>
			</td>
			<td>Configuration to reduce outgoing spam in case of an compromised account. See the documentation for further information: https://mailu.io/1.9/configuration.html?highlight=MESSAGE_RATELIMIT</td>
		</tr>
		<tr>
			<td id="mail--messageSizeLimitInMegabytes"><a href="./values.yaml#L229">mail.messageSizeLimitInMegabytes</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
50
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mailuVersion"><a href="./values.yaml#L220">mailuVersion</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"1.9.26"
</pre>
</div>
			</td>
			<td>Version/tag of mailu images - must be master or a version >= 1.9</td>
		</tr>
		<tr>
			<td id="mariadb--architecture"><a href="./values.yaml#L118">mariadb.architecture</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"standalone"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--auth--database"><a href="./values.yaml#L128">mariadb.auth.database</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--auth--existingSecret"><a href="./values.yaml#L141">mariadb.auth.existingSecret</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--auth--password"><a href="./values.yaml#L135">mariadb.auth.password</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"changeme"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--auth--rootPassword"><a href="./values.yaml#L124">mariadb.auth.rootPassword</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"changeme"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--auth--username"><a href="./values.yaml#L132">mariadb.auth.username</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--enabled"><a href="./values.yaml#L116">mariadb.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--primary--persistence--accessMode"><a href="./values.yaml#L150">mariadb.primary.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--primary--persistence--enabled"><a href="./values.yaml#L148">mariadb.primary.persistence.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mariadb--primary--persistence--size"><a href="./values.yaml#L151">mariadb.primary.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"8Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--image--repository"><a href="./values.yaml#L719">mysql.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"library/mariadb"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--image--tag"><a href="./values.yaml#L720">mysql.image.tag</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"10.4.10"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--livenessProbe--failureThreshold"><a href="./values.yaml#L741">mysql.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--livenessProbe--periodSeconds"><a href="./values.yaml#L740">mysql.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--livenessProbe--timeoutSeconds"><a href="./values.yaml#L742">mysql.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--persistence--accessMode"><a href="./values.yaml#L724">mysql.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--persistence--claimNameOverride"><a href="./values.yaml#L725">mysql.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--persistence--size"><a href="./values.yaml#L722">mysql.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--persistence--storageClass"><a href="./values.yaml#L723">mysql.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--readinessProbe--failureThreshold"><a href="./values.yaml#L745">mysql.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--readinessProbe--periodSeconds"><a href="./values.yaml#L744">mysql.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--readinessProbe--timeoutSeconds"><a href="./values.yaml#L746">mysql.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--resources--limits--cpu"><a href="./values.yaml#L734">mysql.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--resources--limits--memory"><a href="./values.yaml#L733">mysql.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"512Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--resources--requests--cpu"><a href="./values.yaml#L731">mysql.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--resources--requests--memory"><a href="./values.yaml#L730">mysql.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"256Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--startupProbe--failureThreshold"><a href="./values.yaml#L737">mysql.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--startupProbe--periodSeconds"><a href="./values.yaml#L736">mysql.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="mysql--startupProbe--timeoutSeconds"><a href="./values.yaml#L738">mysql.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="nameOverride"><a href="./values.yaml#L42">nameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="nodeSelector"><a href="./values.yaml#L46">nodeSelector</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="persistence--accessMode"><a href="./values.yaml#L208">persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="persistence--single_pvc"><a href="./values.yaml#L206">persistence.single_pvc</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Setings for a single volume for all apps. Set single_pvc: false to use a per app volume and set the properties in <app>.persistence (ex. admin.persistence)</td>
		</tr>
		<tr>
			<td id="persistence--size"><a href="./values.yaml#L207">persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--containerSecurityContext"><a href="./values.yaml#L474">postfix.containerSecurityContext</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--image--repository"><a href="./values.yaml#L471">postfix.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/postfix"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--livenessProbe--failureThreshold"><a href="./values.yaml#L499">postfix.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--livenessProbe--periodSeconds"><a href="./values.yaml#L498">postfix.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--livenessProbe--timeoutSeconds"><a href="./values.yaml#L500">postfix.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--persistence--accessMode"><a href="./values.yaml#L482">postfix.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--persistence--claimNameOverride"><a href="./values.yaml#L483">postfix.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--persistence--size"><a href="./values.yaml#L480">postfix.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--persistence--storageClass"><a href="./values.yaml#L481">postfix.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--readinessProbe--failureThreshold"><a href="./values.yaml#L503">postfix.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--readinessProbe--periodSeconds"><a href="./values.yaml#L502">postfix.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--readinessProbe--timeoutSeconds"><a href="./values.yaml#L504">postfix.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--resources--limits--cpu"><a href="./values.yaml#L492">postfix.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--resources--limits--memory"><a href="./values.yaml#L491">postfix.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"2Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--resources--requests--cpu"><a href="./values.yaml#L489">postfix.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"500m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--resources--requests--memory"><a href="./values.yaml#L488">postfix.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"2Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--startupProbe--failureThreshold"><a href="./values.yaml#L495">postfix.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--startupProbe--periodSeconds"><a href="./values.yaml#L494">postfix.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postfix--startupProbe--timeoutSeconds"><a href="./values.yaml#L496">postfix.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--architecture"><a href="./values.yaml#L160">postgresql.architecture</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"standalone"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--database"><a href="./values.yaml#L177">postgresql.auth.database</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--enablePostgresUser"><a href="./values.yaml#L165">postgresql.auth.enablePostgresUser</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--existingSecret"><a href="./values.yaml#L179">postgresql.auth.existingSecret</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--password"><a href="./values.yaml#L174">postgresql.auth.password</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"changeme"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--postgresPassword"><a href="./values.yaml#L168">postgresql.auth.postgresPassword</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"changeme"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--secretKeys--adminPasswordKey"><a href="./values.yaml#L185">postgresql.auth.secretKeys.adminPasswordKey</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"postgres-password"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--secretKeys--replicationPasswordKey"><a href="./values.yaml#L187">postgresql.auth.secretKeys.replicationPasswordKey</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"replication-password"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--secretKeys--userPasswordKey"><a href="./values.yaml#L186">postgresql.auth.secretKeys.userPasswordKey</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"password"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--auth--username"><a href="./values.yaml#L171">postgresql.auth.username</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--enabled"><a href="./values.yaml#L158">postgresql.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postgresql--primary--persistence--enabled"><a href="./values.yaml#L191">postgresql.primary.persistence.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="postmaster"><a href="./values.yaml#L226">postmaster</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"postmaster"
</pre>
</div>
			</td>
			<td>local part of the postmaster email address (Mailu will use @$DOMAIN as domain part)</td>
		</tr>
		<tr>
			<td id="redis--image--repository"><a href="./values.yaml#L439">redis.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"redis"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--image--tag"><a href="./values.yaml#L440">redis.image.tag</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"5-alpine"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--livenessProbe--failureThreshold"><a href="./values.yaml#L461">redis.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--livenessProbe--periodSeconds"><a href="./values.yaml#L460">redis.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--livenessProbe--timeoutSeconds"><a href="./values.yaml#L462">redis.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--persistence--accessMode"><a href="./values.yaml#L444">redis.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--persistence--claimNameOverride"><a href="./values.yaml#L445">redis.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--persistence--size"><a href="./values.yaml#L442">redis.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--persistence--storageClass"><a href="./values.yaml#L443">redis.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--readinessProbe--failureThreshold"><a href="./values.yaml#L465">redis.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--readinessProbe--periodSeconds"><a href="./values.yaml#L464">redis.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--readinessProbe--timeoutSeconds"><a href="./values.yaml#L466">redis.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--resources--limits--cpu"><a href="./values.yaml#L454">redis.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--resources--limits--memory"><a href="./values.yaml#L453">redis.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"300Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--resources--requests--cpu"><a href="./values.yaml#L451">redis.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--resources--requests--memory"><a href="./values.yaml#L450">redis.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--startupProbe--failureThreshold"><a href="./values.yaml#L457">redis.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--startupProbe--periodSeconds"><a href="./values.yaml#L456">redis.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="redis--startupProbe--timeoutSeconds"><a href="./values.yaml#L458">redis.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--enabled"><a href="./values.yaml#L654">roundcube.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Enable deployment of Roundcube webmail</td>
		</tr>
		<tr>
			<td id="roundcube--image--repository"><a href="./values.yaml#L658">roundcube.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/roundcube"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--livenessProbe--failureThreshold"><a href="./values.yaml#L682">roundcube.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--livenessProbe--periodSeconds"><a href="./values.yaml#L681">roundcube.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--livenessProbe--timeoutSeconds"><a href="./values.yaml#L683">roundcube.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--logLevel"><a href="./values.yaml#L656">roundcube.logLevel</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Set the log level for Roundcube</td>
		</tr>
		<tr>
			<td id="roundcube--persistence--accessMode"><a href="./values.yaml#L664">roundcube.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--persistence--claimNameOverride"><a href="./values.yaml#L665">roundcube.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--persistence--size"><a href="./values.yaml#L662">roundcube.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--persistence--storageClass"><a href="./values.yaml#L663">roundcube.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--readinessProbe--failureThreshold"><a href="./values.yaml#L686">roundcube.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--readinessProbe--periodSeconds"><a href="./values.yaml#L685">roundcube.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--readinessProbe--timeoutSeconds"><a href="./values.yaml#L687">roundcube.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--resources--limits--cpu"><a href="./values.yaml#L675">roundcube.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--resources--limits--memory"><a href="./values.yaml#L674">roundcube.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--resources--requests--cpu"><a href="./values.yaml#L672">roundcube.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--resources--requests--memory"><a href="./values.yaml#L671">roundcube.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--startupProbe--failureThreshold"><a href="./values.yaml#L678">roundcube.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--startupProbe--periodSeconds"><a href="./values.yaml#L677">roundcube.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--startupProbe--timeoutSeconds"><a href="./values.yaml#L679">roundcube.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="roundcube--uri"><a href="./values.yaml#L668">roundcube.uri</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"/roundcube"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--image--repository"><a href="./values.yaml#L576">rspamd.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/rspamd"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--livenessProbe--failureThreshold"><a href="./values.yaml#L599">rspamd.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--livenessProbe--periodSeconds"><a href="./values.yaml#L598">rspamd.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--livenessProbe--timeoutSeconds"><a href="./values.yaml#L600">rspamd.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--persistence--accessMode"><a href="./values.yaml#L582">rspamd.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--persistence--claimNameOverride"><a href="./values.yaml#L583">rspamd.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--persistence--size"><a href="./values.yaml#L580">rspamd.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"1Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--persistence--storageClass"><a href="./values.yaml#L581">rspamd.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--readinessProbe--failureThreshold"><a href="./values.yaml#L603">rspamd.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--readinessProbe--periodSeconds"><a href="./values.yaml#L602">rspamd.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--readinessProbe--timeoutSeconds"><a href="./values.yaml#L604">rspamd.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--resources--limits--cpu"><a href="./values.yaml#L592">rspamd.resources.limits.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--resources--limits--memory"><a href="./values.yaml#L591">rspamd.resources.limits.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"200Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--resources--requests--cpu"><a href="./values.yaml#L589">rspamd.resources.requests.cpu</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100m"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--resources--requests--memory"><a href="./values.yaml#L588">rspamd.resources.requests.memory</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"100Mi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--startupProbe--failureThreshold"><a href="./values.yaml#L595">rspamd.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
90
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--startupProbe--periodSeconds"><a href="./values.yaml#L594">rspamd.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd--startupProbe--timeoutSeconds"><a href="./values.yaml#L596">rspamd.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd_clamav_persistence--accessMode"><a href="./values.yaml#L567">rspamd_clamav_persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd_clamav_persistence--claimNameOverride"><a href="./values.yaml#L568">rspamd_clamav_persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd_clamav_persistence--single_pvc"><a href="./values.yaml#L569">rspamd_clamav_persistence.single_pvc</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd_clamav_persistence--size"><a href="./values.yaml#L565">rspamd_clamav_persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="rspamd_clamav_persistence--storageClass"><a href="./values.yaml#L566">rspamd_clamav_persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="secretKey"><a href="./values.yaml#L19">secretKey</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>The secret key is required for protecting authentication cookies and must be set individually for each deployment If empty, a random secret key will be generated and saved in a secret</td>
		</tr>
		<tr>
			<td id="subnet"><a href="./values.yaml#L217">subnet</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"10.42.0.0/16"
</pre>
</div>
			</td>
			<td>Change this if you're using different address ranges for pods</td>
		</tr>
		<tr>
			<td id="tolerations"><a href="./values.yaml#L50">tolerations</a></td>
			<td>
object
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Tolerations for pod assignment</td>
		</tr>
		<tr>
			<td id="webdav--enabled"><a href="./values.yaml#L691">webdav.enabled</a></td>
			<td>
bool
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Enable deployment of WebDAV server (using Radicale)</td>
		</tr>
		<tr>
			<td id="webdav--image--repository"><a href="./values.yaml#L694">webdav.image.repository</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"mailu/radicale"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--livenessProbe--failureThreshold"><a href="./values.yaml#L710">webdav.livenessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
3
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--livenessProbe--periodSeconds"><a href="./values.yaml#L709">webdav.livenessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--livenessProbe--timeoutSeconds"><a href="./values.yaml#L711">webdav.livenessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--persistence--accessMode"><a href="./values.yaml#L700">webdav.persistence.accessMode</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ReadWriteOnce"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--persistence--claimNameOverride"><a href="./values.yaml#L701">webdav.persistence.claimNameOverride</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--persistence--size"><a href="./values.yaml#L698">webdav.persistence.size</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"20Gi"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--persistence--storageClass"><a href="./values.yaml#L699">webdav.persistence.storageClass</a></td>
			<td>
string
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--readinessProbe--failureThreshold"><a href="./values.yaml#L714">webdav.readinessProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--readinessProbe--periodSeconds"><a href="./values.yaml#L713">webdav.readinessProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--readinessProbe--timeoutSeconds"><a href="./values.yaml#L715">webdav.readinessProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--startupProbe--failureThreshold"><a href="./values.yaml#L706">webdav.startupProbe.failureThreshold</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
30
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--startupProbe--periodSeconds"><a href="./values.yaml#L705">webdav.startupProbe.periodSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
10
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="webdav--startupProbe--timeoutSeconds"><a href="./values.yaml#L707">webdav.startupProbe.timeoutSeconds</a></td>
			<td>
int
</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td></td>
		</tr>
	</tbody>
</table>

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
