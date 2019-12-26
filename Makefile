%.json : %.yml
	yq r -j $< > $@

plan: przestrzen.tf config.json
	terraform plan -var-file config.json

apply: przestrzen.tf config.json
	terraform apply -var-file config.json

provision:
	ansible-playbook -e @config.yml wp.yml

.PHONY: plan apply provision
