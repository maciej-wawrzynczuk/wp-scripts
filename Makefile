%.json : %.yml
	yq r -j $< > $@

plan: przestrzen.tf config.json
	terraform plan -var-file config.json

apply: przestrzen.tf config.json
	terraform apply -var-file config.json

provision: salts.txt
	ansible-playbook -e @config.yml wp.yml

destroy: przestrzen.tf config.json
	terraform destroy -var-file config.json

salts.txt:
	curl https://api.wordpress.org/secret-key/1.1/salt/ > $@

.PHONY: plan apply provision

