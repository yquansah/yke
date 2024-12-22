## Scripts

This directory is for running kubeadm commands on either the worker or control plane nodes.

To initialize a control plane nodes:

```sh
cat init_control_plane.sh | ssh -i /path/to/private/key user@remote_host 'bash -s'
```

To reset the control plane nodes:

```sh
cat reset_control_plane.sh | ssh -i /path/to/private/key user@remote_host 'bash -s'
```

To join worker nodes:

```sh
cat join_worker_node.sh | ssh -i /path/to/private/key user@remote_host 'bash -s'
```
