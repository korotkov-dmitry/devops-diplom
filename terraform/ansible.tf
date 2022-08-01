resource "null_resource" "wait-clear-ssh" {
  provisioner "local-exec" {
    command = "sleep 40"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -f '/home/vagrant/.ssh/known_hosts' -R 'korotkovdmitry.ru'"
  }

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "null_resource" "playbook" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ..//ansible/playbook.yml -i ..//ansible/inventory"
  }

  depends_on = [
    null_resource.wait-clear-ssh
  ]
}
