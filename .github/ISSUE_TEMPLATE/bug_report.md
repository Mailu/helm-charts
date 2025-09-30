---
name: Bug report
about: Create a report to help us improve the Mailu Helm chart
title: "[BUG] - "
labels: bug
assignees: ""
---

**Describe the bug**
A clear and concise description of what the bug is. Indicate if this is a regression (e.g., it worked in a previous version XX).

**To Reproduce**
Steps to reproduce the behavior (include specific Helm or Kubernetes commands if applicable):

1. Go to '...'
2. Run command '...'
3. Observe output '...'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment (please complete the following information):**

- **Helm Chart Version**: [e.g., 1.0.0]
- **Helm Version**: [e.g., v3.12.0]
- **Kubernetes Version**: [e.g., 1.21.1]
- **Kubernetes Platform**: [e.g., GKE, Rancher2, EKS, AKS, Minikube]
- **Mailu Version**: [e.g., 1.7]

**Values.yaml Configuration**
Please provide your `values.yaml` configuration file or the relevant parts of it (ensure sensitive data is redacted).

```yaml
# Example:
mailu:
  domain: "example.com"
  secretKey: "<redacted>"
  ...

**Additional information**
Add any other context about the problem here, such as logs, error messages, or configurations.
```
