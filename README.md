# prometheus
A high-availability prometheus stack for Docker Swarm

## Getting Started

As a recommendation, you should only have Prometheus deployed per Docker Swarm Cluster.

Before you start, you need to carefully plan your deployment.
- Consider how many instances you want to deploy.
- Node placement for each instance.
- etc...

You might need to create swarm-scoped overlay network called `dockerswarm_monitoring` for all the stacks to communicate if you haven't already.

```sh
$ docker network create --scope swarm --driver overlay --attachable dockerswarm_monitoring
```

You also need to create extra networks for prometheus agents (such as cAdvisor, Node Exporter... etc.) and external resource (aka. your application).

```sh
$ docker network create --scope swarm --driver overlay --attachable prometheus # for external resource
$ docker network create --scope swarm --driver overlay --attachable prometheus_agents
```

We provided a base configuration file for Prometheus. You can find it in the `config` folder.  
Please make a copy as `configs/prometheus.yml`, make sure to change the following values:

```yaml
# configs/prometheus.yml
global:
  external_labels:
      cluster: demo
      namespace: demo
      __replica__: replica-{{ env "TASK_SLOT"}}

remote_write:
  - url: http://mimir:3200/api/v1/push
    headers:
      "X-Scope-OrgID": demo

alerting:
  alertmanagers:
    # Remote alertmanager
    - url: http://alertmanager:9093
```

And add any additional configuration you need to `configs/prometheus.yml`.

## How it works

This setup uses Docker Metrics API to collect metrics from the Docker daemon.
> See https://docs.docker.com/config/daemon/prometheus/ for more information.

**Adding a new service to monitor**
```yaml
# docker-compose.yml
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    # ...
    networks:
      - prometheus_agents
    deploy:
      labels:
        io.prometheus.enable: "true"
        io.prometheus.scrape_port: "8080" # optional
        io.prometheus.scrape_scheme: "http" # optional
        io.prometheus.metrics_path: "/metrics" # optional
```

## High Availability

This stack is designed to be highly available.

You MUST enable `remote_write` in the `configs/prometheus.yml` file to make it work.

By default, it will deploy 2 replicas of Prometheus. Having more than 2 replicas is way too much for a small cluster.  
If you want to change the number of replicas, you can do so by changing the `replicas` value in the `docker-compose.yml` file.

![High Availability](https://github.com/YouMightNotNeedKubernetes/prometheus/assets/4363857/3a3e407e-d95a-4cad-afe6-f0259803943d)

### Server placement

A `node.labels.prometheus` label is used to determine which nodes the service can be deployed on.

The deployment uses both placement **constraints** & **preferences** to ensure that the servers are spread evenly across the Docker Swarm manager nodes and only **ALLOW** one replica per node.

![placement_prefs](https://docs.docker.com/engine/swarm/images/placement_prefs.png)

> See https://docs.docker.com/engine/swarm/services/#control-service-placement for more information.

#### List the nodes
On the manager node, run the following command to list the nodes in the cluster.

```sh
docker node ls
```

#### Add the label to the node
On the manager node, run the following command to add the label to the node.

Repeat this step for each node you want to deploy the service to. Make sure that the number of node updated matches the number of replicas you want to deploy.

**Example deploy service with 2 replicas**:
```sh
docker node update --label-add prometheus=true <node-1>
docker node update --label-add prometheus=true <node-2>
```

## Deployment

To deploy the stack, run the following command:

```sh
$ make deploy
```

## Destroy

To destroy the stack, run the following command:

```sh
$ make destroy
```
