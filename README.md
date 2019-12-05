# Hive 3 - '~~Site~~ Service Reliability Engineering'

Hive DBA's are nearly non-existent.  Why?  I have a theory about this and much of it is due to how Hive / Hadoop have been marketed to users as well as the expectations of the technology.

Traditional Databases have a deep history of DBA's involvement while running production systems.

## Pre-Requisites

1. Ansible - I'll use this in some places to demostrate and record a reproducible process.
2. [Hadoop CLI](https://github.com/dstreev/hadoop-cli) (Version 2.0.22+) - Is an interactive HDFS Client with a lot of helpful features that make traversing HDFS fast and convient.
3. Beeline