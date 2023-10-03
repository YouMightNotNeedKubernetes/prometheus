docker_stack_name = prometheus


it:
	@echo "make [configs|deploy|destroy]"

.PHONY: configs
configs:
	test -f "configs/prometheus.yml" || cp configs/prometheus.base.yml configs/prometheus.yml

deploy: configs
	docker stack deploy -c docker-compose.yml $(docker_stack_name)

destroy:
	docker stack rm $(docker_stack_name)
