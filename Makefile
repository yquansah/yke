.PHONY: tf-plan yke-start yke-destroy init-argocd clean

tf-plan:
	cd terraform && terraform plan

yke-start:
	bash setup.sh

yke-destroy: clean
	cd terraform && terraform destroy -auto-approve

clean:
	@if [ -f admin.conf ]; then \
		rm admin.conf; \
		echo "Removed admin.conf"; \
	fi
	@if [ -f command.txt ]; then \
		rm command.txt; \
		echo "Removed command.txt"; \
	fi

init-argocd:
	cd argocd && bash init_argocd.sh
