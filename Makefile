.PHONY: tf-plan tf-apply tf-destroy init-control-plane join-worker-node reset-control-plane init-argo

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

init-argo:
	cd argo && bash init_argo.sh
