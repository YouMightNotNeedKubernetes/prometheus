# promstack
A high-availability prometheus stack for Docker Swarm

## Getting Started

You might need to create swarm-scoped overlay network called `dockerswarm_monitoring` for all the stacks to communicate if you haven't already.

```sh
$ docker network create --driver overlay --attachable dockerswarm_monitoring
```

We provided a base configuration file for Prometheus. You can find it in the `config` folder.  
Please make a copy as `configs/prometheus.yml`, make sure to change the following values:

```yml
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
