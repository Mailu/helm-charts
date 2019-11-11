#!/bin/bash

cat << EOF
<html>
<body>
<h1>Public repo for Mailu helm chart</h1>
<h2>Installation</h2>
<p>
<pre>
helm repo add mailu https://mailu.github.io/helm-charts/
helm install mailu/mailu
</pre>
</p>
<h2>Available versions</h2>
<ul>
EOF

grep index.yaml -e "version:" | awk -F': ' '{print "<li>"$2"</li>"}' | sort -n -r

cat << EOF
</ul>
</body>
</html>
EOF

