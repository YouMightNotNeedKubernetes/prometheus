# prometheus
A high-availability prometheus stack for Docker Swarm

## Getting Started

You might need to create swarm-scoped overlay network called `dockerswarm_monitoring` for all the stacks to communicate if you haven't already.

```sh
$ docker network create --driver overlay --attachable dockerswarm_monitoring
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
      - dockerswarm_monitoring
    deploy:
      labels:
        io.prometheus.job: "cadvisor"
        io.prometheus.port: "8080" # optional
        io.prometheus.scheme: "http" # optional
        io.prometheus.metrics_path: "/metrics" # optional
```
