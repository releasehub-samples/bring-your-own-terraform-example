# Release Application Template & Environment Variables

This directory contains Release example Application Template & Environment Variable configuration files. 

## GitOps Enabled

Release [GitOps](https://docs.releasehub.com/reference-guide/gitops) is an **opt-in** feature that allows you to store your Release [Application Template](https://docs.releasehub.com/reference-guide/application-settings/application-template) and [Environment Variables](https://docs.releasehub.com/reference-guide/application-settings/default-environment-variables) in your repository.

**GitOps is not enabled by default**. 

When GitOps is not enabled, please note that: 

* When you **first** create a new Release Application (not the environment itself), Release **will** use your `.release.yaml` files, if present. 

* Changes to your Application and Variable Templates pushed to your remote repo will **not** update remote environment state.