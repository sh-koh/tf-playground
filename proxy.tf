resource "libvirt_volume" "proxy" {
  name   = "proxy"
  pool   = "img"
  base_volume_id = libvirt_volume.debian12.id
}

resource "libvirt_cloudinit_disk" "cloudinit_proxy" {
  name      = "proxy.iso"
  pool      = "img"
  user_data = templatefile("${path.module}/cloud_init.cfg", { hostname = "proxy" })
  network_config = templatefile("${path.module}/network_config.cfg", {
    ip_address    = "192.168.10.10"
    ip_gateway    = "192.168.10.1"
    ip_nameserver = "192.168.10.1"
  })
}

resource "libvirt_domain" "proxy" {
  name      = "proxy"
  cloudinit = libvirt_cloudinit_disk.cloudinit_proxy.id
  memory    = 1024
  vcpu      = 1
  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id   = libvirt_network.testing.id
    hostname   = "proxy"
    addresses  = ["192.168.10.10"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.proxy.id
  }
}
