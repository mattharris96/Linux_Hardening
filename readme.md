# Linux Hardening Automation Project
## project start date: 2024/11/08
The initial scope of this project is to create a method to easily and quickly deploy Secuirty Hardened Debian virtal machines, via a series of automation and scripting tools. then to covert those machines to easily and rapidly deployable OVA images which can act as a Secure golden image. The deployment for my specific case will be via amazon AWS.

```mermaid
graph TB
  subgraph AWS_EC2 [AWS EC2]
    Host1[Ubuntu Server - Host 1]
    Host1 -->|deploy| HardenedHost[CIS Hardened Ubuntu Machine]

    subgraph Host1Details [Host 1 Details]
      Ansible[Ansible]
      Terraform[Terraform]
    end
    Host1Details --> Host1
  end