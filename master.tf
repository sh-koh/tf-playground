resource "libvirt_volume" "master" {
  name   = "master"
  pool   = "img"
  base_volume_id = libvirt_volume.debian12.id
}

resource "libvirt_cloudinit_disk" "cloudinit_master" {
  name      = "master.iso"
  pool      = "img"
  user_data = templatefile("${path.module}/cloud_init.cfg", { hostname = "master" })
  network_config = templatefile("${path.module}/network_config.cfg", {
    ip_address    = "192.168.10.30"
    ip_gateway    = "192.168.10.1"
    ip_nameserver = "192.168.10.1"
  })
}

resource "libvirt_domain" "master" {
  name      = "master"
  cloudinit = libvirt_cloudinit_disk.cloudinit_master.id
  memory    = 4096
  vcpu      = 4
  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id   = libvirt_network.testing.id
    hostname   = "master"
    addresses  = ["192.168.10.30"]
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
    volume_id = libvirt_volume.master.id
  }
}
