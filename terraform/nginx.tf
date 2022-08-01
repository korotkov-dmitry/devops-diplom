resource "yandex_compute_instance" "nginx" {
  name = "nginx"
  zone = "ru-central1-a"
  hostname = "korotkovdmitry.ru"
  allow_stopping_for_update = true
  
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
    }
  }

  network_interface {
    subnet_id       = yandex_vpc_subnet.subnet-0.id
    nat             = true
    nat_ip_address  = var.stat_ip
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}