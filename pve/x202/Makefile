include .env
export

.PHONY: k6-build
build:
	docker run --rm -u "$(id -u):$(id -g)" -v "${PWD}:/xk6" grafana/xk6 build \
  		--with github.com/grafana/xk6-output-influxdb \
  		--with github.com/grafana/xk6-dashboard

.PHONY: k6-grafana
k6-grafana:
	./k6 run -o xk6-influxdb=http://localhost:8086 $(addprefix ./docker/config/k6/scripts/,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: k6-dashboard
k6-dashboard:
	$(eval SCRIPT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval TIMESTAMP := $(shell date +%Y%m%d%H%M))
	./k6 run -o dashboard=export=./docker/data/k6/dashboards/$(SCRIPT_NAME)-$(TIMESTAMP).html ./docker/config/k6/scripts/$(SCRIPT_NAME).js

%:
	@:
