resource "yandex_compute_instance" "runner" {
  name     = "runner"
  hostname = "runner.korotkovdmitry.ru"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size     = 6
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-0.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}