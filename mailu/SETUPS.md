# Mailu setups with the Helm Chart

WIP: This document shall describe and show how Mailu can be setup with the Helm Chart.

## Simple (using hostPort)

This is a simple setup to make Mailu services available from the internet.
Cert-manager is used to get a certificate for the Ingress. The same certificate is used by the `front` deployment for
mail services.

How traffic is routed from a public IP address to individual K8s nodes is out of scope and must be taken care of individually.
Typically K8s nodes have private IP addresses and a Service of type LoadBalancer is used to make services available on public IPs.

- Ingress for Webmail (80, 443)
- Host port for Mail ports (25, 110, 143, 465, 587, 993, 995)

```mermaid
flowchart TD
    %% entities
    Internet(Internet)
    Front(Mailu front\nsingle pod)
    Webmail(Mailu webmail\nsingle pod)
    Ingress(Ingress\nservice)

    Internet --> Node1
    Internet --> Node2

    subgraph Node1[k8s node 1]
        IngressController1 -- 80/443 --> Ingress
    end

    subgraph Node2[k8s node 2]
        HostPort -- 25/.../995 --> Front
        IngressController2 -- 80/443 --> Ingress
        Ingress --> Front
        Front --> Webmail
    end
```


## K8s nodes with public IPs
!Warning section: traffic between pods is unencrypted, use istio or similar to ensure traffic between k8s nodes is encrypted.
