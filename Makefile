.PHONY: all fmt lint scan test clean act-test

all: fmt lint scan test act-test

fmt:
	terraform fmt -recursive
	ruff format scripts/

lint:
	terraform validate
	tflint
	ruff check scripts/
	ruff check tests/

scan:
	checkov -d terraform/
	bandit -r scripts/
	bandit -r tests/

test:
	python3 -m unittest discover -s tests

clean:
	rm -rf terraform/.terraform terraform/tfplan

act-test: ## Run GitHub Actions workflows locally
	act -W .github/workflows/security-lint.yml
