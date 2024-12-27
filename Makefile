.PHONY: tf-plan tf-apply tf-destroy init-control-plane join-worker-node reset-control-plane init-argo clean

tf-plan:
	cd terraform && terraform plan

tf-apply:
	cd terraform && terraform apply -auto-approve

tf-destroy:
	cd terraform && terraform destroy -auto-approve

init-control-plane:
	cd scripts && bash init_control_plane.sh

join-worker-node:
	cd scripts && bash join_worker_node.sh

reset-control-plane:
	cd scripts && bash reset_control_plane.sh

init-argocd:
	cd argocd && bash init_argocd.sh

clean:
	rm admin.conf ./scripts/init_output.txt
