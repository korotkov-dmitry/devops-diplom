resource "yandex_compute_instance" "db01" {
  name     = "db01"
  hostname = "db01.korotkovdmitry.ru"

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
    nat       = true #false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "db02" {
  name     = "db02"
  hostname = "db02.korotkovdmitry.ru"

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
    nat       = true #false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}