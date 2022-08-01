resource "yandex_vpc_network" "default" {
  name = "net"

}

resource "yandex_vpc_subnet" "subnet-0" {
  name           = "subnet-0"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}